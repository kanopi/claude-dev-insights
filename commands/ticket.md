---
argument-hint: [ticket-number] [additional-tickets...]
description: Set ticket number(s) for the current session
---

# Session Ticket Tracking

!```bash
# Get session ID and log directory
SESSION_ID=$(jq -r '.session_id // "unknown"' ~/.claude/current_session.json 2>/dev/null || echo "unknown")
LOG_DIR="$HOME/.claude/session-logs"
mkdir -p "$LOG_DIR"

# Get or create session start context file
START_CONTEXT="$LOG_DIR/.session-start-${SESSION_ID}"

# Parse ticket arguments
TICKETS="$ARGUMENTS"

if [ -z "$TICKETS" ]; then
  echo "❌ Error: Please provide at least one ticket number."
  echo "Usage: /ticket JIRA-1234 [JIRA-5678 ...]"
  exit 0
fi

# If context file exists, read current tickets and append
if [ -f "$START_CONTEXT" ]; then
  # Read existing tickets from JSON
  EXISTING_TICKETS=$(jq -r '.ticket_number // ""' "$START_CONTEXT" 2>/dev/null)

  # Append new tickets to existing ones
  if [ -n "$EXISTING_TICKETS" ]; then
    ALL_TICKETS="$EXISTING_TICKETS $TICKETS"
  else
    ALL_TICKETS="$TICKETS"
  fi

  # Update the ticket_number field in the JSON file
  TEMP_FILE=$(mktemp)
  jq --arg tickets "$ALL_TICKETS" '.ticket_number = $tickets' "$START_CONTEXT" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$START_CONTEXT"

  echo "✅ Tickets updated for session: $ALL_TICKETS"
else
  # No session start context yet - create one with minimal info
  cat > "$START_CONTEXT" <<EOF
{
  "session_id": "$SESSION_ID",
  "ticket_number": "$TICKETS",
  "start_timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
  echo "✅ Tickets set for session: $TICKETS"
fi

# Show current ticket list
echo ""
echo "📋 Current tickets for this session:"
jq -r '.ticket_number' "$START_CONTEXT" 2>/dev/null | tr ' ' '\n' | sed 's/^/   - /'
```

---

**Session ticket(s) have been recorded.** These will be included in the session analytics CSV when the session ends.

You can add more tickets at any time by running `/ticket` again with additional ticket numbers.
