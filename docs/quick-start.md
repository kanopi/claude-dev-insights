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
- **UserPromptSubmit** extracts ticket numbers and session topics from structured commands (#ticket:, #topic:)
- **SessionEnd** logs comprehensive analytics when you exit

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

## Next Steps

- [Session Analytics](features/session-analytics.md) - Deep dive into analytics
- [Google Sheets Setup](google-sheets/setup.md) - Enable cloud sync
- [View Analytics](usage/view-analytics.md) - Analyze your session data

---

## Getting Help

- **Documentation**: Browse this site
- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Community**: [GitHub Discussions](https://github.com/kanopi/claude-dev-insights/discussions)
