# Quick Start

Get started with Claude Dev Insights in 5 minutes.

---

## Your First Session

After [installing the plugin](installation.md), start a Claude Code session. You'll immediately see:

```
🚀 Session Started: 2025-11-12 08:45:23
   Project: my-project | CMS: drupal | Environment: ddev
   Git Branch: main | Uncommitted Changes: 0
   Dependencies: 47
```

This is the **SessionStart hook** profiling your development environment.

---

## Working with Claude

Use Claude Code normally. The plugin runs silently in the background:

- **SessionStart** logs your environment at session start
- **PreToolUse** checks every tool call for security and cost issues
- **PostToolUse** validates code quality after edits
- **SessionEnd** logs comprehensive analytics when you exit

---

## Security Protection in Action

Try to read a sensitive file:

```
> Read the .env file
```

You'll see:

```
🔒 BLOCKED: Access to sensitive file '.env'
   This file matches a security pattern and cannot be accessed.
   If this is a false positive, update: config/security-patterns.json
```

The **PreToolUse security scanner** blocked the operation.

---

## Cost Warnings

If you make expensive tool calls (WebSearch, WebFetch) and approach your budget:

```
💰 COST WARNING: Session approaching budget limit
   Tool: WebSearch (expensive operation)
   Check your usage with: cat ~/.claude/session-logs/sessions.csv
```

---

## Quality Automation

Edit a PHP file with quality issues:

```
> Edit src/api.php and add a function
```

After the edit, the **PostToolUse quality automator** runs PHPCS:

```
⚠️  Code Quality Warning: src/api.php
   Linter: phpcs

   FILE: /path/to/src/api.php
   Line 42: Missing function docblock
   Line 58: Variable $data is undefined
```

---

## Ending Your Session

When you finish (via `/clear` or exit):

```
📊 Session logged to: /Users/username/.claude/session-logs/sessions.csv
   Duration: 1847s | Messages: 107 | Tokens: 19146 | Cost: $2.1847
```

---

## View Your Analytics

**Quick summary:**

```bash
cat ~/.claude/session-logs/sessions.csv | tail -1
```

**Calculate total cost:**

```bash
awk -F, 'NR>1 {sum+=$14} END {print "Total: $"sum}' ~/.claude/session-logs/sessions.csv
```

**Cost by project:**

```bash
awk -F, 'NR>1 {cost[$3]+=$14} END {for(p in cost) print p": $"cost[p]}' \
  ~/.claude/session-logs/sessions.csv
```

**View security events:**

```bash
cat ~/.claude/session-logs/security.log
```

**View quality events:**

```bash
cat ~/.claude/session-logs/quality.log
```

---

## Generate Reports

Use the Python analytics library:

```bash
# JSON report
python3 ~/.claude/plugins/cache/claude-dev-insights/lib/analytics.py json

# Markdown report
python3 ~/.claude/plugins/cache/claude-dev-insights/lib/analytics.py markdown
```

Example output:

```markdown
# Claude Code Analytics Report

Generated: 2025-11-12T10:30:00

## Session Overview

- **Total Sessions**: 15
- **Total Cost**: $12.45
- **Total Duration**: 4.2 hours
- **Total Tokens**: 187,234
- **Projects**: 3

## Top Tools Used

- **Bash**: 45 uses
- **Read**: 38 uses
- **Edit**: 24 uses
- **Write**: 15 uses
```

[Full usage examples →](usage/view-analytics.md)

---

## Customize Configuration

All hooks are configurable via JSON files.

**Security patterns:**

```bash
# View default patterns
cat ~/.claude/plugins/cache/claude-dev-insights/config/security-patterns.json

# Edit to customize
vim ~/.claude/plugins/cache/claude-dev-insights/config/security-patterns.json
```

**Cost thresholds:**

```bash
# Set your budget
vim ~/.claude/plugins/cache/claude-dev-insights/config/cost-thresholds.json
```

Example:

```json
{
  "session_budget": 10.00,
  "warn_at_percent": 80,
  "expensive_tools": ["WebSearch", "WebFetch", "Task"]
}
```

**Quality rules:**

```bash
# Configure linters
vim ~/.claude/plugins/cache/claude-dev-insights/config/quality-rules.json
```

[Full configuration guide →](configuration/overview.md)

---

## Enable Google Sheets Sync

Sync your data to Google Sheets for team collaboration:

1. **Install Python dependencies:**
   ```bash
   pip3 install gspread oauth2client
   ```

2. **Run setup:**
   ```bash
   python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --setup
   ```

3. **Test:**
   ```bash
   python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --test
   ```

Once configured, every session automatically syncs:

```
📊 Session logged to: ~/.claude/session-logs/sessions.csv
   Duration: 1847s | Messages: 107 | Tokens: 19146 | Cost: $2.1847
✅ Synced 1 session to Google Sheets
```

[Full Google Sheets guide →](google-sheets/setup.md)

---

## Common Workflows

### Track Costs Across Projects

```bash
# Total cost per project
awk -F, 'NR>1 {cost[$3]+=$14} END {for(p in cost) print p": $"cost[p]}' \
  ~/.claude/session-logs/sessions.csv

# This month's costs
awk -F, 'NR>1 && $1 ~ /2025-11/ {sum+=$14} END {print "November: $"sum}' \
  ~/.claude/session-logs/sessions.csv
```

### Review Security Events

```bash
# Today's blocked operations
grep "BLOCKED" ~/.claude/session-logs/security.log | grep "$(date '+%Y-%m-%d')"

# All security events for a session
grep "abc123-session-id" ~/.claude/session-logs/security.log
```

### Monitor Code Quality

```bash
# Recent linter failures
grep "LINT_FAIL" ~/.claude/session-logs/quality.log | tail -10

# Invalid commit messages
grep "COMMIT_INVALID" ~/.claude/session-logs/quality.log
```

---

## Disable Features

**Disable specific hooks:**

Edit `~/.claude/plugins/cache/claude-dev-insights/hooks/hooks.json` and remove hooks:

```json
{
  "hooks": {
    "SessionStart": [...],
    "SessionEnd": [...],
    "PreToolUse": [],        ← Disabled
    "PostToolUse": []        ← Disabled
  }
}
```

**Disable Google Sheets sync:**

```bash
python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --disable
```

**Disable plugin entirely:**

```bash
claude plugins disable claude-dev-insights
```

---

## Next Steps

- [Session Analytics](features/session-analytics.md) - Deep dive into analytics
- [Security Scanner](features/security-scanner.md) - Configure security rules
- [Cost Guard](features/cost-guard.md) - Set up budget management
- [Quality Automator](features/quality-automator.md) - Configure code quality checks

---

## Getting Help

- **Documentation**: Browse this site
- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Community**: [GitHub Discussions](https://github.com/kanopi/claude-dev-insights/discussions)
