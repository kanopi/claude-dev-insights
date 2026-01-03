#!/bin/bash

# UserPromptSubmit Hook - Extract ticket numbers and topics from structured commands
# Format: #ticket: 123456
#         #topic: feat: Doing the thing

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON input
session_id=$(echo "$input" | jq -r '.session_id')
prompt=$(echo "$input" | jq -r '.prompt // ""')

# Log directory
log_dir="$HOME/.claude/session-logs"
mkdir -p "$log_dir"

# Session start context file
start_context_file="$log_dir/.session-start-${session_id}"

# Extract ticket numbers (format: #ticket: 123456 or #ticket: JIRA-123 ABC-456)
if echo "$prompt" | grep -qE '^#ticket:\s*'; then
    new_tickets=$(echo "$prompt" | grep -oE '^#ticket:\s*.*' | sed -E 's/^#ticket:\s*//' | sed -E 's/\s*#topic:.*//' | xargs)
else
    new_tickets=""
fi

# Extract topic (format: #topic: feat: Description of work)
if echo "$prompt" | grep -qE '#topic:\s*'; then
    new_topic=$(echo "$prompt" | grep -oE '#topic:\s*.*' | sed -E 's/^#topic:\s*//' | xargs)
else
    new_topic=""
fi

# If neither command found, exit silently
if [ -z "$new_tickets" ] && [ -z "$new_topic" ]; then
    exit 0
fi

# Get existing data
existing_tickets=""
if [ -f "$start_context_file" ]; then
    existing_tickets=$(jq -r '.ticket_number // ""' "$start_context_file" 2>/dev/null)
fi

# Combine tickets if new ones provided
if [ -n "$new_tickets" ]; then
    if [ -n "$existing_tickets" ]; then
        all_tickets="$existing_tickets $new_tickets"
    else
        all_tickets="$new_tickets"
    fi
else
    all_tickets="$existing_tickets"
fi

# Update or create context file
if [ -f "$start_context_file" ]; then
    temp_file=$(mktemp)
    if [ -n "$all_tickets" ] && [ -n "$new_topic" ]; then
        jq --arg tickets "$all_tickets" --arg topic "$new_topic" \
           '.ticket_number = $tickets | .summary = $topic' \
           "$start_context_file" > "$temp_file"
    elif [ -n "$all_tickets" ]; then
        jq --arg tickets "$all_tickets" '.ticket_number = $tickets' "$start_context_file" > "$temp_file"
    elif [ -n "$new_topic" ]; then
        jq --arg topic "$new_topic" '.summary = $topic' "$start_context_file" > "$temp_file"
    fi
    mv "$temp_file" "$start_context_file"
else
    # Create new context file
    cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "ticket_number": "$all_tickets",
  "summary": "$new_topic",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
fi

# Output minimal confirmation
output=""
if [ -n "$all_tickets" ]; then
    output="Ticket: $all_tickets"
fi
if [ -n "$new_topic" ]; then
    if [ -n "$output" ]; then
        output="$output | Topic: $new_topic"
    else
        output="Topic: $new_topic"
    fi
fi

if [ -n "$output" ]; then
    echo "[$output]"
fi

exit 0
