# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-12

### Added
- **Initial release** - Comprehensive developer analytics and productivity plugin for Claude Code
- **SessionEnd Hook** - Automatic session analytics and usage tracking
  - Logs 21 data points per session to CSV (`~/.claude/session-logs/sessions.csv`)
  - Tracks duration, messages, tokens, costs, tool usage, and more
  - Optional Google Sheets integration for cloud sync and team sharing
  - Automatically enabled when plugin is active (no configuration needed)
  - Migrated from cms-cultivator plugin
- **SessionStart Hook** - Development environment profiling
  - Logs session initialization context
  - Detects CMS type (Drupal/WordPress)
  - Checks environment type (DDEV/Docker/local)
  - Counts dependencies (Composer/npm)
  - Tracks git branch and uncommitted changes
  - Creates context file for SessionEnd reference
- **PreToolUse Hook** - Security scanner and cost guard
  - Blocks access to sensitive files (.env, *.key, credentials)
  - Detects and blocks dangerous commands (rm -rf, chmod 777, sudo rm)
  - Tracks session costs and warns when approaching budget limits
  - Logs all security events to audit trail
  - Configurable security patterns via JSON
- **PostToolUse Hook** - Quality automator and compliance checker
  - Auto-runs linters after file edits (PHPCS, ESLint, Stylelint, Flake8)
  - Validates commit messages (conventional commits enforcement)
  - Logs quality violations and improvements
  - Configurable quality rules via JSON
- **Shared Libraries**
  - `lib/common.sh` - Bash utility functions (logging, CMS detection, git operations)
  - `lib/analytics.py` - Python analytics library with reporting capabilities
- **Configuration System**
  - `config/security-patterns.json` - Customizable security rules
  - `config/cost-thresholds.json` - Configurable budget limits
  - `config/quality-rules.json` - Customizable quality standards
- **Hook Configuration**
  - `hooks/hooks.json` - Centralized hook registration
  - Uses `${CLAUDE_PLUGIN_ROOT}` for portable paths
- **Comprehensive Documentation**
  - README.md with quick start and usage examples
  - Session End hook detailed documentation
  - Google Sheets setup guide
  - Configuration reference

### Features
- **Automatic Analytics** - Zero configuration required
- **Security Protection** - Real-time blocking of risky operations
- **Cost Management** - Budget tracking and warnings
- **Quality Enforcement** - Automated code quality checks
- **Team Collaboration** - Google Sheets integration for team insights
- **Privacy First** - Logs metadata only, never actual code or conversations
- **Highly Configurable** - Customize all rules via JSON config files
- **Extensible Architecture** - Easy to add more hooks in future versions

### Technical Details
- **4 Hook Types**: SessionStart, SessionEnd, PreToolUse, PostToolUse
- **21+ CSV Fields**: Comprehensive session data tracking
- **3 Log Files**: sessions.csv, security.log, quality.log
- **Bash + Python**: Hooks written in Bash, analytics in Python
- **JSON Configuration**: All rules customizable via JSON files
- **Google Sheets API**: Optional cloud sync via gspread library

### Requirements
- Claude Code CLI
- jq (JSON parsing)
- Python 3 (optional, for Google Sheets and analytics)
- gspread, oauth2client (optional, for Google Sheets sync)
- Linters (optional, for quality automation)

### Known Limitations
- PreToolUse cannot block operations in default permission mode (requires restricted mode)
- PostToolUse cannot block retroactively (operations already completed)
- Date parsing in SessionEnd hook is macOS-specific (uses `date -j`)
- Google Sheets sync requires manual setup (service account credentials)

### Migration Notes
- This plugin was extracted from cms-cultivator v0.3.x
- Existing CSV data from cms-cultivator is fully compatible
- Google Sheets config from cms-cultivator can be reused
- File paths have changed: `session-end-logger/` → `session-end/`

[1.0.0]: https://github.com/kanopi/claude-dev-insights/releases/tag/1.0.0
