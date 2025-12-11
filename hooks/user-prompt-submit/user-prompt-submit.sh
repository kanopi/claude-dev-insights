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

# Check if this message contains both ticket: and summary: commands (order-agnostic)
if echo "$prompt" | grep -qiE 'ticket:' && echo "$prompt" | grep -qiE 'summary:'; then
    # Determine which comes first
    if echo "$prompt" | grep -qiE '^ticket:\s*.*summary:\s*'; then
        # ticket: comes first, then summary:
        new_tickets=$(echo "$prompt" | sed -E 's|^ticket:\s*||i' | sed -E 's|\s*summary:.*||i' | xargs)
        new_summary=$(echo "$prompt" | sed -E 's|^.*summary:\s*||i' | xargs)
    elif echo "$prompt" | grep -qiE '^summary:\s*.*ticket:\s*'; then
        # summary: comes first, then ticket:
        new_summary=$(echo "$prompt" | sed -E 's|^summary:\s*||i' | sed -E 's|\s*ticket:.*||i' | xargs)
        new_tickets=$(echo "$prompt" | sed -E 's|^.*ticket:\s*||i' | xargs)
    else
        # Both exist but not at the start - extract both
        new_tickets=$(echo "$prompt" | grep -oiE 'ticket:\s*[^s]*' | sed -E 's|ticket:\s*||i' | sed -E 's|\s*summary:.*||i' | xargs)
        new_summary=$(echo "$prompt" | grep -oiE 'summary:\s*.*' | sed -E 's|summary:\s*||i' | sed -E 's|\s*ticket:.*||i' | xargs)
    fi

    if [ -n "$new_tickets" ] || [ -n "$new_summary" ]; then
        # Get existing tickets if any
        existing_tickets=""
        if [ -f "$start_context_file" ]; then
            existing_tickets=$(jq -r '.ticket_number // ""' "$start_context_file" 2>/dev/null)
        fi

        # Combine existing and new tickets
        if [ -n "$new_tickets" ]; then
            if [ -n "$existing_tickets" ]; then
                all_tickets="$existing_tickets $new_tickets"
            else
                all_tickets="$new_tickets"
            fi
        else
            all_tickets="$existing_tickets"
        fi

        # Update or create context file with both ticket and summary
        if [ -f "$start_context_file" ]; then
            temp_file=$(mktemp)
            if [ -n "$all_tickets" ] && [ -n "$new_summary" ]; then
                jq --arg tickets "$all_tickets" --arg summary "$new_summary" \
                   '.ticket_number = $tickets | .summary = $summary' \
                   "$start_context_file" > "$temp_file"
            elif [ -n "$all_tickets" ]; then
                jq --arg tickets "$all_tickets" '.ticket_number = $tickets' "$start_context_file" > "$temp_file"
            elif [ -n "$new_summary" ]; then
                jq --arg summary "$new_summary" '.summary = $summary' "$start_context_file" > "$temp_file"
            fi
            mv "$temp_file" "$start_context_file"
        else
            # Create new context file
            cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "ticket_number": "$all_tickets",
  "summary": "$new_summary",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
        fi

        # Output confirmation
        echo "⏺ I've captured your session metadata:"
        echo ""
        if [ -n "$all_tickets" ]; then
            echo "  - Ticket: $all_tickets"
        fi
        if [ -n "$new_summary" ]; then
            echo "  - Summary: $new_summary"
        fi
        echo ""
        echo "  This information will be automatically logged to your session CSV"
        echo "  (~/.claude/session-logs/sessions.csv) when the session ends, making it"
        echo "  easy to track your work and generate reports."

        # Exit successfully - combined command handled
        exit 0
    fi
fi

# Check if this is a ticket: command (without summary)
if echo "$prompt" | grep -qiE '^ticket:\s*'; then
    # Extract ticket numbers from the command
    new_tickets=$(echo "$prompt" | sed -E 's|^ticket:\s*||i' | xargs)

    if [ -n "$new_tickets" ]; then
        # Get existing tickets
        existing_tickets=""
        if [ -f "$start_context_file" ]; then
            existing_tickets=$(jq -r '.ticket_number // ""' "$start_context_file" 2>/dev/null)
        fi

        # Combine existing and new tickets
        if [ -n "$existing_tickets" ]; then
            all_tickets="$existing_tickets $new_tickets"
        else
            all_tickets="$new_tickets"
        fi

        # Update or create context file
        if [ -f "$start_context_file" ]; then
            temp_file=$(mktemp)
            jq --arg tickets "$all_tickets" '.ticket_number = $tickets' "$start_context_file" > "$temp_file"
            mv "$temp_file" "$start_context_file"
        else
            cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "ticket_number": "$all_tickets",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
        fi

        # Output confirmation
        echo "✅ Ticket(s) set: $all_tickets"
        echo ""
        echo "📋 All tickets for this session:"
        echo "$all_tickets" | tr ' ' '\n' | sed 's/^/   - /'

        # Exit successfully - ticket command handled
        exit 0
    fi
fi

# Check if this is a summary: command (without ticket)
if echo "$prompt" | grep -qiE '^summary:\s*'; then
    # Extract summary text from the command
    new_summary=$(echo "$prompt" | sed -E 's|^summary:\s*||i' | xargs)

    if [ -n "$new_summary" ]; then
        # Update or create context file
        if [ -f "$start_context_file" ]; then
            temp_file=$(mktemp)
            jq --arg summary "$new_summary" '.summary = $summary' "$start_context_file" > "$temp_file"
            mv "$temp_file" "$start_context_file"
        else
            cat > "$start_context_file" <<EOF
{
  "session_id": "$session_id",
  "summary": "$new_summary",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
        fi

        # Output confirmation
        echo "✅ Summary set: $new_summary"

        # Exit successfully - summary command handled
        exit 0
    fi
fi

# Check if we've already auto-detected tickets for this session
processed_flag="$log_dir/.ticket-processed-${session_id}"

# If we've already auto-detected, exit early
if [ -f "$processed_flag" ]; then
    exit 0
fi

# Mark this session as having auto-detection processed
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

# Try to extract ticket patterns from the prompt (auto-detection)
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
    echo "📋 Detected ticket(s): $tickets (use 'ticket: TICKET-123' to add more)"
else
    # No tickets detected - add context suggesting the user set one
    cat <<EOF
💡 Tip: Use 'ticket:' to track what you're working on (e.g., ticket: JIRA-1234)
💡 Tip: Use 'summary:' to describe this session (e.g., summary: Refactoring authentication module)
EOF
fi

exit 0
