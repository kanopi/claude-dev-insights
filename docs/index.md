# Claude Dev Insights

**Comprehensive developer analytics and productivity insights for Claude Code.**

Automatically track every Claude Code session with detailed metrics and optional Google Sheets sync.

---

## Features at a Glance

### 📊 Session Analytics
Track every Claude Code session with 29 data points including duration, messages, tokens, costs, and tool usage. Export to CSV and optionally sync to Google Sheets for team collaboration.

[Learn more →](features/session-analytics.md)

---

## Quick Install

```bash
# Inside Claude Code CLI
/plugin marketplace add kanopi/claude-toolbox
/plugin install claude-dev-insights@claude-toolbox
```

That's it! All hooks activate automatically when the plugin is enabled.

[Installation guide →](installation.md)

---

## What Gets Tracked

Every session logs to `~/.claude/session-logs/sessions.csv` with:

- **Session metadata**: Timestamp, ID, project name, summary, end reason
- **Duration**: Wall-clock time from start to end (seconds)
- **Activity**: User messages, assistant messages
- **Tokens**: Input, output, cache read, cache write, total
- **Cost**: Estimated USD based on Claude Sonnet 4.5 pricing
- **Tools**: Tool call counts, API time, average call time, top 5 tools
- **Context**: Git branch, Claude Code version, permission mode
- **Environment**: CMS type, environment type, dependencies

[View all data fields →](features/session-analytics.md#csv-columns-29-fields)

---

## How It Works

SessionStart and SessionEnd hooks automatically run in the background when you start and end Claude Code sessions. All data is logged to `~/.claude/session-logs/sessions.csv` and can optionally sync to Google Sheets for team collaboration.

---

## Privacy & Security

**What's logged:**

✅ Session metadata (timestamps, IDs, duration)
✅ Usage statistics (tokens, costs, tool counts)
✅ Session summary (one-line description)
✅ Git context (branch, status, ticket numbers)

**NOT logged:**

❌ Actual code or conversation content
❌ Sensitive data or credentials
❌ File contents or API responses

All data stays on your machine unless you explicitly configure Google Sheets sync.

---

## Requirements

**Required:**
- Claude Code CLI
- `jq` (JSON parsing)
  - macOS: `brew install jq`
  - Linux: `apt-get install jq`

**Optional:**
- Python 3 + `gspread` + `oauth2client` (for Google Sheets sync)

---

## Next Steps

- [Installation Guide](installation.md) - Get up and running in 5 minutes
- [Quick Start](quick-start.md) - Learn the basics
- [Session Analytics](features/session-analytics.md) - Explore all tracked data
- [Google Sheets Setup](google-sheets/setup.md) - Enable cloud sync

---

## Support

- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Source Code**: [GitHub Repository](https://github.com/kanopi/claude-dev-insights)

---

**Created and maintained by [Kanopi Studios](https://kanopi.com)**
