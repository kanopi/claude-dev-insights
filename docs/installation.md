# Installation

Get Claude Dev Insights up and running in 5 minutes.

---

## Prerequisites

**Required:**

- **Claude Code CLI** - The plugin requires Claude Code to be installed
- **jq** - JSON parsing utility (usually pre-installed on macOS/Linux)

Check if `jq` is installed:

```bash
jq --version
```

If not installed:

```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (Fedora/RHEL)
sudo dnf install jq
```

**Optional (for Google Sheets sync):**

- Python 3
- pip package manager

---

## Installation Methods

### Method 1: Via Claude Toolbox Marketplace (Recommended)

```bash
# Inside Claude Code CLI
/plugin marketplace add kanopi/claude-toolbox
/plugin install claude-dev-insights@claude-toolbox
```

### Method 2: Direct Install from GitHub

```bash
# Inside Claude Code CLI
/plugin install https://github.com/kanopi/claude-dev-insights
```

### Method 3: Local Development Install

```bash
# Clone the repository
git clone https://github.com/kanopi/claude-dev-insights.git
cd claude-dev-insights

# Create symlink to Claude Code plugins directory
ln -s $(pwd) ~/.config/claude/plugins/claude-dev-insights

# Enable the plugin
claude plugins enable claude-dev-insights
```

---

## Verification

After installation, verify the plugin is enabled:

```bash
claude plugins list
```

You should see:

```
claude-dev-insights (enabled)
```

---

## First Session

Start a Claude Code session and you'll immediately see the SessionStart hook output:

```
🚀 Session Started: 2025-11-12 08:45:23
   Project: my-project | CMS: drupal | Environment: ddev
   Git Branch: main | Uncommitted Changes: 0
   Dependencies: 47
```

When you end the session (via `/clear` or exit), you'll see:

```
📊 Session logged to: /Users/username/.claude/session-logs/sessions.csv
   Duration: 234s | Messages: 12 | Tokens: 3421 | Cost: $0.3142
```

---

## Verify CSV Creation

Check that the CSV file was created:

```bash
ls -l ~/.claude/session-logs/sessions.csv
```

View the contents:

```bash
cat ~/.claude/session-logs/sessions.csv
```

You should see a header row and at least one data row.

---

## Optional: Google Sheets Setup

If you want to sync session data to Google Sheets:

1. **Install Python dependencies:**
   ```bash
   pip3 install gspread oauth2client
   ```

2. **Run interactive setup:**
   ```bash
   python3 ~/.config/claude/plugins/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --setup
   ```

3. **Test connection:**
   ```bash
   python3 ~/.config/claude/plugins/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --test
   ```

[Full Google Sheets setup guide →](../google-sheets/setup.md)

---

## What's Installed

The plugin creates the following structure:

```
~/.config/claude/plugins/claude-dev-insights/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── hooks.json              # Hook configuration
│   ├── session-start/          # SessionStart hook
│   ├── session-end/            # SessionEnd hook
│   ├── pre-tool-use/           # PreToolUse hook
│   └── post-tool-use/          # PostToolUse hook
├── lib/
│   ├── common.sh               # Bash utilities
│   └── analytics.py            # Python analytics
└── config/                     # Created on first run
    ├── security-patterns.json
    ├── cost-thresholds.json
    └── quality-rules.json
```

---

## Data Storage

The plugin stores data in your home directory:

```
~/.claude/session-logs/
├── sessions.csv        # Session analytics
├── security.log        # Security events
└── quality.log         # Quality events
```

These files are created automatically on first use.

---

## Disabling the Plugin

If you want to disable the plugin temporarily:

```bash
claude plugins disable claude-dev-insights
```

Re-enable it:

```bash
claude plugins enable claude-dev-insights
```

---

## Uninstalling

To completely remove the plugin:

```bash
# Disable first
claude plugins disable claude-dev-insights

# Uninstall
claude plugins uninstall claude-dev-insights

# Optional: Remove data files
rm -rf ~/.claude/session-logs
```

---

## Troubleshooting

### Plugin not loading

Check for errors:

```bash
cat ~/.claude/debug/*.log
```

Verify file permissions:

```bash
ls -la ~/.config/claude/plugins/claude-dev-insights/hooks/
```

All `.sh` files should be executable (`-rwxr-xr-x`).

### jq command not found

The hooks require `jq` for JSON parsing:

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### Permission errors

Ensure log directory is writable:

```bash
mkdir -p ~/.claude/session-logs
chmod 755 ~/.claude/session-logs
```

---

## Next Steps

- [Quick Start Guide](quick-start.md) - Learn how to use the plugin
- [Configuration](configuration/overview.md) - Customize security, cost, and quality rules
- [Google Sheets Setup](google-sheets/setup.md) - Enable cloud sync

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/kanopi/claude-dev-insights/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kanopi/claude-dev-insights/discussions)
- **Documentation**: This site
