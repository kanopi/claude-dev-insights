#!/bin/bash

# PreToolUse Hook - Security Scanner & Cost Guard
# This hook runs before every tool execution to:
# 1. Block access to sensitive files
# 2. Warn on dangerous commands
# 3. Track and limit costs
# 4. Log security events

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON input
tool_name=$(echo "$input" | jq -r '.tool_name')
tool_input=$(echo "$input" | jq -r '.tool_input')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

# Security log location
log_dir="$HOME/.claude/session-logs"
mkdir -p "$log_dir"
security_log="$log_dir/security.log"

# Configuration files
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
    config_dir="$CLAUDE_PLUGIN_ROOT/config"
else
    config_dir="$HOME/.claude/dev-insights/config"
fi

# Load security patterns (create default if not exists)
security_patterns_file="$config_dir/security-patterns.json"
if [ ! -f "$security_patterns_file" ]; then
    mkdir -p "$config_dir"
    cat > "$security_patterns_file" <<'PATTERNS'
{
  "blocked_files": [
    ".env",
    ".env.local",
    "*.key",
    "*.pem",
    "credentials.json",
    "service-account*.json",
    "**/secrets/*",
    ".aws/credentials",
    ".ssh/id_rsa"
  ],
  "sensitive_files": [
    ".git/config",
    "composer.lock",
    "package-lock.json",
    "yarn.lock",
    "settings.php",
    "wp-config.php"
  ],
  "dangerous_commands": [
    "rm -rf /",
    "chmod 777",
    "sudo rm",
    "> /dev/sda",
    "dd if=",
    "mkfs.",
    ":(){ :|:& };:"
  ]
}
PATTERNS
fi

# Load cost thresholds
cost_threshold_file="$config_dir/cost-thresholds.json"
if [ ! -f "$cost_threshold_file" ]; then
    cat > "$cost_threshold_file" <<'THRESHOLDS'
{
  "session_budget": 5.00,
  "warn_at_percent": 80,
  "expensive_tools": ["WebSearch", "WebFetch", "Task"]
}
THRESHOLDS
fi

# Function to check if file path matches blocked pattern
check_file_access() {
    local file_path="$1"
    local patterns=$(jq -r '.blocked_files[]' "$security_patterns_file")

    while IFS= read -r pattern; do
        # Convert glob pattern to regex
        if [[ "$file_path" == $pattern ]]; then
            return 0  # Match found (blocked)
        fi
    done <<< "$patterns"

    return 1  # No match (allowed)
}

# Function to check for dangerous commands
check_dangerous_command() {
    local command="$1"
    local patterns=$(jq -r '.dangerous_commands[]' "$security_patterns_file")

    while IFS= read -r pattern; do
        if [[ "$command" == *"$pattern"* ]]; then
            return 0  # Dangerous command detected
        fi
    done <<< "$patterns"

    return 1  # Safe command
}

# Function to log security event
log_security_event() {
    local event_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$session_id] [$event_type] $message" >> "$security_log"
}

# Function to check session cost
check_session_cost() {
    local csv_file="$log_dir/sessions.csv"
    local budget=$(jq -r '.session_budget' "$cost_threshold_file")
    local warn_percent=$(jq -r '.warn_at_percent' "$cost_threshold_file")

    # Get current session cost if it exists
    if [ -f "$csv_file" ] && [ -n "$session_id" ]; then
        current_cost=$(grep "$session_id" "$csv_file" | tail -1 | cut -d',' -f14)
        if [ -n "$current_cost" ] && [ "$current_cost" != "0" ]; then
            warn_threshold=$(echo "scale=2; $budget * $warn_percent / 100" | bc)
            if (( $(echo "$current_cost > $warn_threshold" | bc -l) )); then
                return 0  # Over threshold
            fi
        fi
    fi

    return 1  # Under threshold
}

# Main security checks based on tool type
action="allow"
reason=""

case "$tool_name" in
    Read|Edit|Write|Glob)
        # Check file access
        file_path=$(echo "$tool_input" | jq -r '.file_path // .path // empty')
        pattern=$(echo "$tool_input" | jq -r '.pattern // empty')

        # Check file_path if present
        if [ -n "$file_path" ] && [ "$file_path" != "null" ]; then
            if check_file_access "$file_path"; then
                action="deny"
                reason="🔒 BLOCKED: Access to sensitive file '$file_path'"
                log_security_event "BLOCKED_FILE" "$tool_name: $file_path"

                # Output denial to Claude
                {
                    echo ""
                    echo "$reason"
                    echo "   This file matches a security pattern and cannot be accessed."
                    echo "   If this is a false positive, update: $security_patterns_file"
                    echo ""
                } >&2
            fi
        fi

        # Check glob pattern for sensitive matches
        if [ -n "$pattern" ] && [ "$pattern" != "null" ]; then
            if [[ "$pattern" == *".env"* ]] || [[ "$pattern" == *".key"* ]]; then
                action="warn"
                reason="⚠️  WARNING: Glob pattern may match sensitive files: $pattern"
                log_security_event "WARN_PATTERN" "$tool_name: $pattern"

                {
                    echo ""
                    echo "$reason"
                    echo "   Proceeding with caution..."
                    echo ""
                } >&2
            fi
        fi
        ;;

    Bash)
        # Check for dangerous commands
        command=$(echo "$tool_input" | jq -r '.command // empty')

        if [ -n "$command" ] && [ "$command" != "null" ]; then
            if check_dangerous_command "$command"; then
                action="deny"
                reason="🚨 BLOCKED: Dangerous command detected"
                log_security_event "BLOCKED_COMMAND" "$command"

                {
                    echo ""
                    echo "$reason"
                    echo "   Command: $command"
                    echo "   This command matches a dangerous pattern and has been blocked."
                    echo "   If this is intentional, update: $security_patterns_file"
                    echo ""
                } >&2
            fi
        fi
        ;;

    WebSearch|WebFetch|Task)
        # Check if expensive tool and warn on budget
        if check_session_cost; then
            log_security_event "COST_WARNING" "$tool_name: Session approaching budget limit"

            {
                echo ""
                echo "💰 COST WARNING: Session approaching budget limit"
                echo "   Tool: $tool_name (expensive operation)"
                echo "   Check your usage with: cat $log_dir/sessions.csv"
                echo ""
            } >&2
        fi
        ;;
esac

# Output response to Claude
if [ "$action" = "deny" ]; then
    # Block the operation
    jq -n \
        --arg reason "$reason" \
        '{
            action: "deny",
            reason: $reason
        }'
    exit 0
elif [ "$action" = "warn" ]; then
    # Allow but log warning
    log_security_event "WARNING" "$reason"
    jq -n '{action: "allow"}'
    exit 0
else
    # Allow operation
    jq -n '{action: "allow"}'
    exit 0
fi
