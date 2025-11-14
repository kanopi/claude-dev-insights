#!/bin/bash

# SessionStart Hook - Log session start context and development environment
# This hook captures the initial state when a Claude Code session begins

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON input
session_id=$(echo "$input" | jq -r '.session_id')
source=$(echo "$input" | jq -r '.source // "new"')
cwd=$(echo "$input" | jq -r '.cwd')

# CSV file location (same as SessionEnd)
log_dir="$HOME/.claude/session-logs"
mkdir -p "$log_dir"
csv_file="$log_dir/sessions.csv"

# Session start timestamp
start_datetime=$(date '+%Y-%m-%d %H:%M:%S')

# Detect project type and environment
cms_type="unknown"
if [ -f "$cwd/composer.json" ]; then
    if grep -q "drupal/core" "$cwd/composer.json" 2>/dev/null; then
        cms_type="drupal"
    elif grep -q "wordpress" "$cwd/composer.json" 2>/dev/null; then
        cms_type="wordpress"
    fi
fi

# Check for DDEV
environment_type="local"
if [ -f "$cwd/.ddev/config.yaml" ]; then
    environment_type="ddev"
fi

# Count dependencies
deps_count=0
if [ -f "$cwd/composer.json" ]; then
    deps_count=$(jq '[.require // {}, ."require-dev" // {}] | add | length' "$cwd/composer.json" 2>/dev/null || echo 0)
fi

# Git context
git_branch="unknown"
uncommitted_changes=0
if [ -d "$cwd/.git" ]; then
    git_branch=$(cd "$cwd" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    uncommitted_changes=$(cd "$cwd" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
fi

# Project name
project_name=$(basename "$cwd")

# User name from git config or system username
user_name=$(git config --global user.name 2>/dev/null || echo "$USER")
# Sanitize for CSV (remove commas and quotes)
user_name=$(echo "$user_name" | sed 's/,/-/g' | sed 's/"//g')

# Output session context to Claude (via CLAUDE_ENV_FILE if needed)
# This makes the context available to Claude in the session
{
    echo "🚀 Session Started: $start_datetime"
    echo "   User: $user_name"
    echo "   Project: $project_name | CMS: $cms_type | Environment: $environment_type"
    echo "   Git Branch: $git_branch | Uncommitted Changes: $uncommitted_changes"
    echo "   Dependencies: $deps_count"
    echo ""
} >&2

# Prompt for optional ticket number
ticket_number=""
if [ -t 1 ]; then
    # Only prompt if stdout is a terminal (user can interact)
    echo "Enter ticket number (optional, press Enter to skip): " >&2
    read -r ticket_number < /dev/tty
    ticket_number=$(echo "$ticket_number" | sed 's/,/-/g' | sed 's/"//g' | xargs)
fi

# Store start context in a temp file for SessionEnd to reference
# This allows SessionEnd to calculate accurate duration and include start context
start_context_file="$log_dir/.session-start-${session_id}"
cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "start_timestamp": "$start_datetime",
  "user": "$user_name",
  "ticket_number": "$ticket_number",
  "project": "$project_name",
  "cms_type": "$cms_type",
  "environment_type": "$environment_type",
  "git_branch": "$git_branch",
  "uncommitted_changes": $uncommitted_changes,
  "dependencies_count": $deps_count,
  "source": "$source"
}
EOF

exit 0
