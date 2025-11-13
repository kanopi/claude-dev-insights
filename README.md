# Claude Dev Insights

![Maintained](https://img.shields.io/maintenance/yes/2025.svg)
[![License](https://img.shields.io/badge/license-GPL--2.0--or--later-blue.svg)](LICENSE.md)

**Comprehensive developer analytics and productivity insights for Claude Code.** Automatically track sessions, enforce security policies, guard against cost overruns, and ensure code quality with 4 intelligent hooks.

---

## Features

### 📊 Session Analytics (SessionStart + SessionEnd)
- **21+ data points per session** - Duration, messages, tokens, costs, tool usage
- **Local CSV storage** - `~/.claude/session-logs/sessions.csv`
- **Google Sheets sync** - Optional cloud backup for team sharing
- **Environment profiling** - CMS detection, dependency tracking, git status

### 🔒 Security Scanner (PreToolUse)
- **Block sensitive file access** - `.env`, `*.key`, credentials, secrets
- **Dangerous command detection** - `rm -rf`, `chmod 777`, `sudo rm`
- **Real-time alerts** - Console warnings before risky operations
- **Security event logging** - Audit trail of blocked operations

### 💰 Cost Guard (PreToolUse)
- **Session budget tracking** - Configurable spending limits
- **Expensive tool warnings** - WebSearch, WebFetch, Task operations
- **Real-time cost alerts** - Stop before exceeding budget
- **Token usage monitoring** - Track cumulative costs per session

### ✅ Quality Automator (PostToolUse)
- **Auto-run linters** - PHPCS, ESLint, Stylelint, Flake8 after edits
- **Commit message validation** - Conventional commits enforcement
- **Code quality logging** - Track violations and improvements
- **Configurable rules** - Customize quality standards

---

## Quick Install

**Via Claude Toolbox Marketplace:**

```bash
# Inside Claude Code CLI
/plugin marketplace add kanopi/claude-toolbox
/plugin install claude-dev-insights@claude-toolbox
```

**Direct Install:**

```bash
# Inside Claude Code CLI
/plugin install https://github.com/kanopi/claude-dev-insights
```

That's it! Hooks activate automatically when the plugin is enabled.

---

## What Gets Tracked

### Session CSV Columns (21 fields)

```csv
timestamp, session_id, project, summary, end_reason, duration_seconds,
user_messages, assistant_messages, input_tokens, output_tokens,
cache_read_tokens, cache_write_tokens, total_tokens, total_cost,
tool_calls, api_time_seconds, avg_call_time_ms, tools_used,
git_branch, claude_version, permission_mode
```

### Example Session Data

```csv
2025-11-12 08:45:23,abc123,my-project,"Feature: User Auth",clear,1847,45,62,203,18943,2841023,198234,3058403,2.1847,38,47,1237,"Bash:12; Read:10; Edit:8; Write:4",main,2.0.36,default
```

---

## Configuration

All hooks are configurable via JSON files in `config/`:

### Security Patterns (`config/security-patterns.json`)

```json
{
  "blocked_files": [".env", "*.key", "credentials.json"],
  "sensitive_files": ["wp-config.php", "settings.php"],
  "dangerous_commands": ["rm -rf /", "chmod 777", "sudo rm"]
}
```

### Cost Thresholds (`config/cost-thresholds.json`)

```json
{
  "session_budget": 5.00,
  "warn_at_percent": 80,
  "expensive_tools": ["WebSearch", "WebFetch", "Task"]
}
```

### Quality Rules (`config/quality-rules.json`)

```json
{
  "auto_lint": {
    "enabled": true,
    "php_files": ["phpcs", "--standard=PSR12"],
    "js_files": ["eslint"]
  },
  "commit_message": {
    "enabled": true,
    "require_type": true,
    "min_length": 10,
    "types": ["feat", "fix", "docs", "style", "refactor", "test", "chore"]
  }
}
```

**Configuration location:**
- Plugin users: `~/.claude/plugins/cache/claude-dev-insights/config/`
- Project install: `$CLAUDE_PROJECT_DIR/.claude/dev-insights/config/`

---

## Console Output Examples

### Session Start
```
🚀 Session Started: 2025-11-12 08:45:23
   Project: my-project | CMS: drupal | Environment: ddev
   Git Branch: feature/auth | Uncommitted Changes: 3
   Dependencies: 47
```

### Security Block
```
🔒 BLOCKED: Access to sensitive file '.env'
   This file matches a security pattern and cannot be accessed.
   If this is a false positive, update: config/security-patterns.json
```

### Cost Warning
```
💰 COST WARNING: Session approaching budget limit
   Tool: WebSearch (expensive operation)
   Check your usage with: cat ~/.claude/session-logs/sessions.csv
```

### Quality Violation
```
⚠️  Code Quality Warning: src/api.php
   Linter: phpcs

   FILE: /path/to/src/api.php
   Line 42: Missing function docblock
   Line 58: Variable $data is undefined

   ... (output truncated, see full results with: phpcs src/api.php)
```

### Session End
```
📊 Session logged to: /Users/username/.claude/session-logs/sessions.csv
   Duration: 1847s | Messages: 107 | Tokens: 19146 | Cost: $2.1847
✅ Synced 1 session to Google Sheets
```

---

## Google Sheets Integration

### Why Use Google Sheets?

- ☁️ **Cloud backup** - Your data is safe in the cloud
- 👥 **Team sharing** - Share insights with your team
- 📊 **Easy visualization** - Built-in charts and pivot tables
- 📱 **Access anywhere** - View on any device
- 🔄 **Real-time sync** - Data updates automatically

### Setup (5 minutes)

1. **Install Python dependencies:**
   ```bash
   pip3 install gspread oauth2client
   ```

2. **Run interactive setup:**
   ```bash
   python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --setup
   ```

3. **Test connection:**
   ```bash
   python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --test
   ```

**Full setup guide:** [`hooks/session-end/README.md`](hooks/session-end/README.md)

---

## Usage Examples

### View Your Analytics

```bash
# View all sessions
cat ~/.claude/session-logs/sessions.csv

# Calculate total cost
awk -F, 'NR>1 {sum+=$14} END {print "Total: $"sum}' ~/.claude/session-logs/sessions.csv

# Cost by project
awk -F, 'NR>1 {cost[$3]+=$14} END {for(p in cost) print p": $"cost[p]}' ~/.claude/session-logs/sessions.csv

# Generate full report
python3 ~/.claude/plugins/cache/claude-dev-insights/lib/analytics.py markdown
```

### View Security Events

```bash
# All security events
cat ~/.claude/session-logs/security.log

# Today's events
grep "$(date '+%Y-%m-%d')" ~/.claude/session-logs/security.log

# Blocked operations
grep "BLOCKED" ~/.claude/session-logs/security.log
```

### View Quality Events

```bash
# All quality events
cat ~/.claude/session-logs/quality.log

# Failed lints
grep "LINT_FAIL" ~/.claude/session-logs/quality.log

# Invalid commits
grep "COMMIT_INVALID" ~/.claude/session-logs/quality.log
```

---

## Disabling Features

### Disable Specific Hooks

Edit `hooks/hooks.json` and remove unwanted hooks, or set them to empty arrays:

```json
{
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": []
  }
}
```

### Disable Google Sheets Sync

```bash
python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --disable
```

### Disable Plugin Entirely

```bash
claude plugins disable claude-dev-insights
```

---

## Privacy & Security

### What's Logged

- ✅ Session metadata (timestamps, IDs, duration)
- ✅ Usage statistics (tokens, costs, tool counts)
- ✅ Session summary (one-line description)
- ✅ Security events (blocked operations)
- ✅ Quality events (linter results)
- ❌ **Not logged:** Actual code, conversation content, sensitive data

### Data Location

- **Local CSV**: `~/.claude/session-logs/sessions.csv` (your machine only)
- **Local logs**: `~/.claude/session-logs/security.log`, `quality.log`
- **Google Sheets**: Only if you explicitly configure it

### Security Best Practices

If using Google Sheets:

1. **Protect credentials** - Keep service account keys private
2. **Set permissions** - Only share sheets with trusted team members
3. **Use dedicated account** - Create service account specifically for this
4. **Rotate keys** - Regularly update service account keys

---

## Requirements

### Required
- **Claude Code CLI** - To run the plugin
- **jq** - JSON parsing (usually pre-installed on macOS/Linux)
  - macOS: `brew install jq`
  - Linux: `apt-get install jq`

### Optional
- **Python 3** - For Google Sheets sync and analytics reports
- **gspread, oauth2client** - `pip3 install gspread oauth2client`
- **Linters** - PHPCS, ESLint, Stylelint, Flake8 (for quality automation)

---

## Documentation

- [Session End Hook README](hooks/session-end/README.md) - Detailed session analytics guide
- [Google Sheets Setup](hooks/session-end/README.md#google-sheets-integration-optional) - Cloud sync configuration
- [Configuration Guide](config/) - Customize security, cost, quality rules

---

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## License

GPL-2.0-or-later - see [LICENSE.md](LICENSE.md) file for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Documentation**: [https://kanopi.github.io/claude-dev-insights/](https://kanopi.github.io/claude-dev-insights/)

---

**Created and maintained by [Kanopi Studios](https://kanopi.com)**
