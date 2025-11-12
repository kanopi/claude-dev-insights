#!/bin/bash

# Common Library - Shared functions for all hooks
# Source this file in hooks with: source "${CLAUDE_PLUGIN_ROOT}/lib/common.sh"

# Get log directory
get_log_dir() {
    echo "$HOME/.claude/session-logs"
}

# Get CSV file path
get_csv_file() {
    echo "$(get_log_dir)/sessions.csv"
}

# Ensure log directory exists
ensure_log_dir() {
    local log_dir=$(get_log_dir)
    mkdir -p "$log_dir"
}

# Log message to file
log_message() {
    local log_file="$1"
    local level="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local session_id="${4:-unknown}"

    echo "[$timestamp] [$session_id] [$level] $message" >> "$log_file"
}

# Detect CMS type from directory
detect_cms_type() {
    local dir="$1"
    local cms_type="unknown"

    if [ -f "$dir/composer.json" ]; then
        if grep -q "drupal/core" "$dir/composer.json" 2>/dev/null; then
            cms_type="drupal"
        elif grep -q "wordpress" "$dir/composer.json" 2>/dev/null; then
            cms_type="wordpress"
        fi
    elif [ -f "$dir/wp-config.php" ]; then
        cms_type="wordpress"
    elif [ -f "$dir/index.php" ] && grep -q "Drupal" "$dir/index.php" 2>/dev/null; then
        cms_type="drupal"
    fi

    echo "$cms_type"
}

# Detect environment type
detect_environment() {
    local dir="$1"
    local env_type="local"

    if [ -f "$dir/.ddev/config.yaml" ]; then
        env_type="ddev"
    elif [ -f "$dir/docker-compose.yml" ]; then
        env_type="docker"
    elif [ -f "$dir/.lando.yml" ]; then
        env_type="lando"
    fi

    echo "$env_type"
}

# Get current git branch
get_git_branch() {
    local dir="$1"
    local branch="unknown"

    if [ -d "$dir/.git" ]; then
        branch=$(cd "$dir" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    fi

    echo "$branch"
}

# Count uncommitted changes
count_uncommitted_changes() {
    local dir="$1"
    local count=0

    if [ -d "$dir/.git" ]; then
        count=$(cd "$dir" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    fi

    echo "$count"
}

# Count dependencies in composer.json
count_composer_deps() {
    local dir="$1"
    local count=0

    if [ -f "$dir/composer.json" ]; then
        count=$(jq '[.require // {}, ."require-dev" // {}] | add | length' "$dir/composer.json" 2>/dev/null || echo 0)
    fi

    echo "$count"
}

# Count dependencies in package.json
count_npm_deps() {
    local dir="$1"
    local count=0

    if [ -f "$dir/package.json" ]; then
        count=$(jq '[.dependencies // {}, .devDependencies // {}] | add | length' "$dir/package.json" 2>/dev/null || echo 0)
    fi

    echo "$count"
}

# Validate JSON file
validate_json() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 1
    fi

    if jq empty "$file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get configuration directory
get_config_dir() {
    if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
        echo "$CLAUDE_PLUGIN_ROOT/config"
    else
        echo "$HOME/.claude/dev-insights/config"
    fi
}

# Load JSON config file with default fallback
load_config() {
    local config_file="$1"
    local default_content="$2"

    if [ ! -f "$config_file" ]; then
        mkdir -p "$(dirname "$config_file")"
        echo "$default_content" > "$config_file"
    fi

    cat "$config_file"
}

# Safe CSV append (escapes quotes and commas)
csv_append() {
    local csv_file="$1"
    shift
    local values=("$@")

    local row=""
    for value in "${values[@]}"; do
        # Escape quotes and wrap in quotes if contains comma
        if [[ "$value" == *","* ]] || [[ "$value" == *"\""* ]]; then
            value=$(echo "$value" | sed 's/"/""/g')
            value="\"$value\""
        fi

        if [ -z "$row" ]; then
            row="$value"
        else
            row="$row,$value"
        fi
    done

    echo "$row" >> "$csv_file"
}

# Print colored output to stderr
print_info() {
    echo "$@" >&2
}

print_success() {
    echo "✅ $@" >&2
}

print_warning() {
    echo "⚠️  $@" >&2
}

print_error() {
    echo "❌ $@" >&2
}

print_security() {
    echo "🔒 $@" >&2
}

print_cost() {
    echo "💰 $@" >&2
}
