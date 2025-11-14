#!/bin/bash

# UserPromptSubmit Hook - Auto-detect ticket numbers from user messages
# This hook extracts ticket numbers from the first user message if not already set

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON input
session_id=$(echo "$input" | jq -r '.session_id')
prompt=$(echo "$input" | jq -r '.prompt // ""')
cwd=$(echo "$input" | jq -r '.cwd')

# Log directory
log_dir="$HOME/.claude/session-logs"
mkdir -p "$log_dir"

# Session start context file
start_context_file="$log_dir/.session-start-${session_id}"

# Check if we've already processed a message for this session
processed_flag="$log_dir/.ticket-processed-${session_id}"

# If we've already processed a message, exit early
if [ -f "$processed_flag" ]; then
    exit 0
fi

# Mark this session as processed
touch "$processed_flag"

# Check if ticket is already set
existing_ticket=""
if [ -f "$start_context_file" ]; then
    existing_ticket=$(jq -r '.ticket_number // ""' "$start_context_file" 2>/dev/null)
fi

# If ticket already exists, nothing to do
if [ -n "$existing_ticket" ]; then
    exit 0
fi

# Try to extract ticket patterns from the prompt
# Common patterns: JIRA-123, GH-456, #789, PROJ-123, etc.
tickets=$(echo "$prompt" | grep -oE '\b[A-Z]+-[0-9]+\b|#[0-9]+\b' | tr '\n' ' ' | xargs)

# If we found tickets, store them
if [ -n "$tickets" ]; then
    if [ -f "$start_context_file" ]; then
        # Update existing context file
        temp_file=$(mktemp)
        jq --arg tickets "$tickets" '.ticket_number = $tickets' "$start_context_file" > "$temp_file"
        mv "$temp_file" "$start_context_file"
    else
        # Create new context file
        cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "ticket_number": "$tickets",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
    fi

    # Output to Claude as additional context
    echo "📋 Detected ticket(s): $tickets (use /ticket to add more)"
else
    # No tickets detected - add context suggesting the user set one
    cat <<EOF
💡 Tip: Use /ticket to track what you're working on (e.g., /ticket JIRA-1234)
EOF
fi

exit 0
