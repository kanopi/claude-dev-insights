# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-11-14

### Added
- **Multi-Ticket Tracking** - Track multiple tickets per session with automatic detection and manual entry
  - **Automatic Detection** - UserPromptSubmit hook extracts ticket patterns (JIRA-123, GH-456, #789) from first user message
  - **/ticket Slash Command** - New `/ticket` command to manually set or add tickets throughout session
  - **Incremental Tracking** - Run `/ticket` multiple times to accumulate tickets: `JIRA-1234 JIRA-5678`
  - **Multiple Patterns** - Supports common ticket formats: `JIRA-123`, `GH-456`, `PROJ-789`, `#123`
  - All tickets logged to CSV as space-separated list in `ticket_number` column

### Changed
- **SessionStart Hook** - Removed broken interactive prompt and unnecessary features
  - Removed `/dev/tty` interactive input (didn't work with Claude Code's async hook model)
  - Removed `CLAUDE_TICKET` environment variable support (replaced by auto-detection)
  - Removed `.claude-ticket` file support (replaced by auto-detection)
  - Simplified to only log session context and create initial context file
- **Hook Configuration** - Fixed SessionStart to only run on startup/clear, not resume (compact)
  - Added `source` matcher to prevent hook from running on session resume
  - Fixes hanging issue when resuming sessions

### Fixed
- Session resume no longer hangs due to SessionStart hook attempting to prompt for input
- SessionStart hook no longer blocks or waits for user input

### Documentation
- Updated README.md with Quick Start: Ticket Tracking section
- Updated docs/features/session-analytics.md with comprehensive ticket tracking guide
- Updated CLAUDE.md with ticket tracking implementation details
- Removed references to deprecated environment variable and file-based methods

## [1.1.1] - 2025-11-14

### Fixed
- **SessionStart Hook** - Fixed ticket number prompt not appearing during interactive sessions
  - Changed stdin check `[ -t 0 ]` to stdout check `[ -t 1 ]` at hooks/session-start/session-start.sh:73
  - Modified `read` command to read from `/dev/tty` instead of stdin at hooks/session-start/session-start.sh:76
  - The hook now correctly prompts users for ticket numbers even when stdin contains JSON input from Claude Code

### Technical Details
- The issue occurred because stdin was already consumed by the `cat` command that reads hook input JSON
- Reading from `/dev/tty` allows interactive prompts even when stdin is redirected or exhausted
- This is the standard solution for scripts that need both piped input and interactive user prompts

## [1.1.0] - 2025-11-14

### Added
- **BATS Test Suite** - Comprehensive test coverage with 220+ assertions
  - Plugin manifest validation
  - Hook script validation (executability, syntax, structure)
  - Configuration file validation (JSON syntax, required fields)
  - Documentation completeness checks
  - Security scanning (hardcoded secrets, merge conflicts)
  - CSV field count and column order validation
  - Cost calculation formula verification
  - Integration tests for hook interactions
- **GitHub Actions CI/CD** - Automated testing and deployment
  - `.github/workflows/test.yml` - 8 test jobs running on PRs and main branch
  - `.github/workflows/deploy-docs.yml` - Automated docs deployment with Zensical
  - BATS tests, hook validation, config validation, security scanning
  - Documentation build verification and broken link detection
- **CLAUDE.md** - AI assistant project context
  - Comprehensive architecture overview
  - Development workflow documentation
  - Testing instructions
  - Common tasks and troubleshooting guide
- **Enhanced Documentation**
  - Complete 28-field CSV column table with descriptions and examples
  - Detailed Google Sheets setup guide with troubleshooting section
  - Consolidated documentation in `/docs` folder
  - Security best practices for Google Sheets integration
- **README Badges** - Status indicators for tests, releases, and documentation
  - Test status badge linked to GitHub Actions
  - Last commit and release badges
  - Documentation badge linked to GitHub Pages site

### Changed
- **CSV Column Order** - Moved `summary` to 6th position (after project, before cms_type)
  - Improves readability when viewing CSV files
  - **Breaking Change**: Existing CSV parsing scripts may need column position updates
  - Old position: 11th column
  - New position: 6th column
- **Documentation Structure** - Removed redundant `hooks/session-end/README.md`
  - Content migrated to `/docs/features/session-analytics.md`
  - All documentation now centralized in `/docs` folder
- **Field Count Correction** - Updated all documentation from 21 to 28 CSV fields
  - README.md now states "28 data points per session"
  - Documentation accurately reflects all tracked fields
- **Hook Behavior Clarification** - Documentation now explains SessionStart/SessionEnd run in background
  - Removed misleading console output examples for these hooks
  - Clarified that PreToolUse and PostToolUse provide visible feedback

### Fixed
- **Documentation Accuracy** - Corrected field count from 21 to 28 across all docs
- **CSV Examples** - Updated examples to match actual implementation
- **Internal Links** - Fixed documentation links to use correct paths

### Technical Details
- **Test Coverage**: 220+ assertions across 8 test job categories
- **CSV Fields**: Now correctly documented as 28 fields (was incorrectly stated as 21)
- **CI/CD**: Automated testing on every PR and docs deployment on merge to main
- **Documentation**: Built with Zensical and deployed to GitHub Pages

## [1.0.1] - 2025-11-13

### Fixed
- **Bash Syntax Error** - Fixed regex pattern escaping in `hooks/post-tool-use/post-tool-use.sh` line 193 that caused hook failures with syntax errors on every tool use
- **Documentation Paths** - Updated all path references from `~/.config/claude/plugins/` to correct marketplace installation path `~/.claude/plugins/cache/` across:
  - README.md (5 instances)
  - docs/installation.md (5 instances)
  - docs/quick-start.md (7 instances)
- **Google Sheets Script Paths** - Corrected setup and test command paths in `hooks/session-end/sync-to-google-sheets.py` to match actual marketplace installation location

### Changed
- All documentation now consistently references the correct marketplace plugin path
- Google Sheets setup output now provides accurate test command

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
