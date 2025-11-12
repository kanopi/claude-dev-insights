#!/bin/bash

# PostToolUse Hook - Quality Automator & Compliance Checker
# This hook runs after tool execution to:
# 1. Auto-run linters and formatters
# 2. Check code quality standards
# 3. Validate commit messages
# 4. Log operation timing

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON input
tool_name=$(echo "$input" | jq -r '.tool_name')
tool_input=$(echo "$input" | jq -r '.tool_input')
tool_response=$(echo "$input" | jq -r '.tool_response')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

# Quality log location
log_dir="$HOME/.claude/session-logs"
mkdir -p "$log_dir"
quality_log="$log_dir/quality.log"

# Configuration
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
    config_dir="$CLAUDE_PLUGIN_ROOT/config"
else
    config_dir="$HOME/.claude/dev-insights/config"
fi

# Load quality rules
quality_rules_file="$config_dir/quality-rules.json"
if [ ! -f "$quality_rules_file" ]; then
    mkdir -p "$config_dir"
    cat > "$quality_rules_file" <<'RULES'
{
  "auto_lint": {
    "enabled": true,
    "php_files": ["phpcs", "--standard=PSR12"],
    "js_files": ["eslint"],
    "jsx_files": ["eslint"],
    "ts_files": ["eslint"],
    "tsx_files": ["eslint"],
    "py_files": ["flake8"],
    "css_files": ["stylelint"],
    "scss_files": ["stylelint"]
  },
  "commit_message": {
    "enabled": true,
    "require_type": true,
    "require_scope": false,
    "min_length": 10,
    "types": ["feat", "fix", "docs", "style", "refactor", "test", "chore"]
  },
  "test_coverage": {
    "enabled": false,
    "min_coverage": 80
  }
}
RULES
fi

# Function to log quality event
log_quality_event() {
    local event_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$session_id] [$event_type] $message" >> "$quality_log"
}

# Function to get file extension
get_file_extension() {
    local file_path="$1"
    echo "${file_path##*.}"
}

# Function to run linter for file type
run_linter() {
    local file_path="$1"
    local extension=$(get_file_extension "$file_path")

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        return 0
    fi

    # Check if linting is enabled
    auto_lint_enabled=$(jq -r '.auto_lint.enabled' "$quality_rules_file")
    if [ "$auto_lint_enabled" != "true" ]; then
        return 0
    fi

    # Get linter command for file type
    local linter_key="${extension}_files"
    local linter_cmd=$(jq -r --arg key "$linter_key" '.auto_lint[$key] // empty' "$quality_rules_file")

    if [ -z "$linter_cmd" ] || [ "$linter_cmd" = "null" ]; then
        return 0  # No linter configured for this file type
    fi

    # Parse linter command (it's an array in JSON)
    local linter_bin=$(echo "$linter_cmd" | jq -r '.[0]')
    local linter_args=$(echo "$linter_cmd" | jq -r '.[1:] | join(" ")')

    # Check if linter binary exists
    if ! command -v "$linter_bin" &> /dev/null; then
        return 0  # Linter not installed, skip silently
    fi

    # Run linter
    local output
    if output=$($linter_bin $linter_args "$file_path" 2>&1); then
        log_quality_event "LINT_PASS" "$file_path: $linter_bin"
        return 0
    else
        log_quality_event "LINT_FAIL" "$file_path: $linter_bin"
        {
            echo ""
            echo "⚠️  Code Quality Warning: $file_path"
            echo "   Linter: $linter_bin"
            echo ""
            echo "$output" | head -10
            if [ $(echo "$output" | wc -l) -gt 10 ]; then
                echo "   ... (output truncated, see full results with: $linter_bin $file_path)"
            fi
            echo ""
        } >&2
        return 1
    fi
}

# Function to validate commit message
validate_commit_message() {
    local message="$1"

    commit_enabled=$(jq -r '.commit_message.enabled' "$quality_rules_file")
    if [ "$commit_enabled" != "true" ]; then
        return 0
    fi

    # Check minimum length
    min_length=$(jq -r '.commit_message.min_length' "$quality_rules_file")
    if [ ${#message} -lt $min_length ]; then
        log_quality_event "COMMIT_INVALID" "Message too short: $message"
        {
            echo ""
            echo "⚠️  Commit Message Warning: Message too short (min: $min_length chars)"
            echo "   Message: $message"
            echo ""
        } >&2
        return 1
    fi

    # Check for conventional commit type
    require_type=$(jq -r '.commit_message.require_type' "$quality_rules_file")
    if [ "$require_type" = "true" ]; then
        valid_types=$(jq -r '.commit_message.types | join("|")' "$quality_rules_file")
        if ! echo "$message" | grep -qE "^($valid_types)(\(.+\))?:"; then
            log_quality_event "COMMIT_INVALID" "Missing type prefix: $message"
            {
                echo ""
                echo "⚠️  Commit Message Warning: Should start with type prefix"
                echo "   Valid types: $valid_types"
                echo "   Example: feat: add new feature"
                echo "   Message: $message"
                echo ""
            } >&2
            return 1
        fi
    fi

    log_quality_event "COMMIT_VALID" "$message"
    return 0
}

# Main quality checks based on tool type
case "$tool_name" in
    Edit|Write)
        # File was edited or created, run linter
        file_path=$(echo "$tool_input" | jq -r '.file_path // empty')

        if [ -n "$file_path" ] && [ "$file_path" != "null" ]; then
            run_linter "$file_path"
        fi
        ;;

    Bash)
        # Check if this was a git commit
        command=$(echo "$tool_input" | jq -r '.command // empty')

        if [[ "$command" == *"git commit"* ]]; then
            # Extract commit message
            if [[ "$command" =~ -m[[:space:]]+"([^"]+)" ]] || [[ "$command" =~ -m[[:space:]]+'([^']+)' ]]; then
                commit_message="${BASH_REMATCH[1]}"
                validate_commit_message "$commit_message"
            fi
        fi
        ;;
esac

# Always allow tool to complete (this is PostToolUse, can't block retroactively)
exit 0
