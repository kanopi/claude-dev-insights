# Claude Dev Insights

**Comprehensive developer analytics and productivity insights for Claude Code.**

Automatically track sessions, enforce security policies, guard against cost overruns, and ensure code quality with 4 intelligent hooks.

---

## Features at a Glance

### 📊 Session Analytics
Track every Claude Code session with 21+ data points including duration, messages, tokens, costs, and tool usage. Export to CSV and optionally sync to Google Sheets for team collaboration.

[Learn more →](features/session-analytics.md)

### 🔒 Security Scanner
Block access to sensitive files (`.env`, `*.key`, credentials), detect dangerous commands (`rm -rf`, `chmod 777`), and maintain a security audit trail.

[Learn more →](features/security-scanner.md)

### 💰 Cost Guard
Track session costs in real-time, set budget limits, and get warnings before exceeding spending thresholds. Monitor expensive operations like WebSearch and WebFetch.

[Learn more →](features/cost-guard.md)

### ✅ Quality Automator
Automatically run linters after file edits (PHPCS, ESLint, Stylelint, Flake8), validate commit messages, and maintain code quality standards.

[Learn more →](features/quality-automator.md)

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

[View all data fields →](features/session-analytics.md#csv-columns)

---

## Console Output Examples

**Session Start:**
```
🚀 Session Started: 2025-11-12 08:45:23
   Project: my-project | CMS: drupal | Environment: ddev
   Git Branch: feature/auth | Uncommitted Changes: 3
   Dependencies: 47
```

**Security Block:**
```
🔒 BLOCKED: Access to sensitive file '.env'
   This file matches a security pattern and cannot be accessed.
```

**Cost Warning:**
```
💰 COST WARNING: Session approaching budget limit
   Tool: WebSearch (expensive operation)
```

**Quality Violation:**
```
⚠️  Code Quality Warning: src/api.php
   Linter: phpcs
   Line 42: Missing function docblock
```

**Session End:**
```
📊 Session logged to: ~/.claude/session-logs/sessions.csv
   Duration: 1847s | Messages: 107 | Tokens: 19146 | Cost: $2.1847
✅ Synced 1 session to Google Sheets
```

---

## Privacy & Security

**What's logged:**

✅ Session metadata (timestamps, IDs, duration)
✅ Usage statistics (tokens, costs, tool counts)
✅ Session summary (one-line description)
✅ Security events (blocked operations)
✅ Quality events (linter results)

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
- Linters (PHPCS, ESLint, etc.) for quality automation

---

## Next Steps

- [Installation Guide](installation.md) - Get up and running in 5 minutes
- [Quick Start](quick-start.md) - Learn the basics
- [Configuration](configuration/overview.md) - Customize security, cost, and quality rules
- [Google Sheets Setup](google-sheets/setup.md) - Enable cloud sync

---

## Support

- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Source Code**: [GitHub Repository](https://github.com/kanopi/claude-dev-insights)

---

**Created and maintained by [Kanopi Studios](https://kanopi.com)**
