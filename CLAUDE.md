# Claude Dev Insights - Project Context

## Project Overview

Claude Dev Insights is a comprehensive analytics and productivity plugin for Claude Code CLI. It provides automated session tracking, security scanning, cost monitoring, and code quality enforcement through intelligent hooks.

## Architecture

### Core Components

1. **Hooks System** (`hooks/`)
   - **SessionStart**: Captures development environment context when sessions begin
   - **SessionEnd**: Logs comprehensive session statistics to CSV
   - **PreToolUse**: Security scanner and cost guard that blocks risky operations
   - **PostToolUse**: Quality automator that runs linters after file edits

2. **Configuration** (`config/`)
   - `security-patterns.json`: Patterns for blocked files and dangerous commands
   - `cost-thresholds.json`: Session budget limits and expensive tool definitions
   - `quality-rules.json`: Linter configurations and commit message rules

3. **Documentation** (`docs/`)
   - Built with Zensical (MkDocs-compatible)
   - Deployed to GitHub Pages at https://kanopi.github.io/claude-dev-insights/

### Data Collection

**Session CSV Format (28 fields):**
- Location: `~/.claude/session-logs/sessions.csv`
- Contains: timestamps, user info, project context, token usage, costs, tool usage, git status
- Optional sync to Google Sheets for team collaboration

**Security & Quality Logs:**
- `~/.claude/session-logs/security.log`: Blocked operations and security events
- `~/.claude/session-logs/quality.log`: Linter results and commit validations

## Key Technologies

- **Shell Scripts**: Bash for hook implementations
- **Python**: Google Sheets sync, analytics (optional)
- **jq**: JSON parsing in shell scripts
- **Zensical**: Documentation site generator
- **BATS**: Testing framework

## Development Workflow

### Making Changes

1. **Hooks**: Edit shell scripts in `hooks/*/` directories
2. **Config**: Update JSON files in `config/`
3. **Docs**: Edit markdown in `docs/`, Zensical builds from `mkdocs.yml`
4. **Tests**: Run `bats tests/test-plugin.bats` before committing

### Testing Locally

```bash
# Run all tests
bats tests/test-plugin.bats

# Test specific hook
bash hooks/session-end/session-end.sh < test_input.json

# Build docs locally
zensical build
zensical serve
```

### Release Process

1. Update version in `.claude-plugin/plugin.json`
2. Update `CHANGELOG.md`
3. Commit changes
4. Create git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
5. Push: `git push origin main --tags`

## Plugin Structure

```
.claude-plugin/
  plugin.json          # Plugin manifest
hooks/
  hooks.json           # Hook definitions
  session-start/
    session-start.sh   # Environment profiling
  session-end/
    session-end.sh     # Session logging
    sync-to-google-sheets.py  # Optional cloud sync
  pre-tool-use/
    pre-tool-use.sh    # Security & cost guards
  post-tool-use/
    post-tool-use.sh   # Quality automation
config/
  *.json              # Configuration files
docs/
  *.md                # Documentation content
tests/
  test-plugin.bats    # BATS test suite
```

## Important Notes

### Security

- **Never log actual code or conversation content** - only metadata
- Sensitive file patterns in `config/security-patterns.json` block access
- Service account credentials for Google Sheets must be kept private

### Cost Calculation

Based on Claude Sonnet 4.5 pricing (January 2025):
- Input tokens: $3.00 per million
- Output tokens: $15.00 per million
- Cache write: $3.75 per million
- Cache read: $0.30 per million

### Hook Behavior

- **SessionStart/SessionEnd**: Run automatically, output to stderr (may not be visible in console)
- **PreToolUse**: Can block operations, provides feedback
- **PostToolUse**: Runs after tool execution, provides quality warnings

### CSV Column Order

The summary column is the 6th field (after project, before cms_type) for better readability when viewing CSV files.

## Common Tasks

### Adding a New Hook

1. Create script in `hooks/new-hook/`
2. Add entry to `hooks/hooks.json`
3. Add tests to `tests/test-plugin.bats`
4. Document in `docs/`

### Adding a New Config Option

1. Add to appropriate JSON in `config/`
2. Update hook script to read new config
3. Document in `docs/configuration/`
4. Add test for validation

### Updating Documentation

1. Edit markdown in `docs/`
2. Update `mkdocs.yml` if adding new pages
3. Test locally: `zensical serve`
4. Push to main - GitHub Actions auto-deploys

## Dependencies

### Required
- `jq` - JSON parsing in shell scripts
- Claude Code CLI - The plugin host

### Optional
- Python 3 - For Google Sheets sync
- `gspread`, `oauth2client` - Python packages for Sheets API
- Linters - PHPCS, ESLint, Stylelint, Flake8 (for quality automation)

## Troubleshooting

### Hooks Not Running
- Check `~/.claude/debug/` for errors
- Verify hooks.json syntax
- Ensure scripts are executable (`chmod +x`)

### CSV Not Writing
- Check permissions on `~/.claude/session-logs/`
- Verify jq is installed
- Check transcript file exists and is readable

### Google Sheets Sync Failing
- Verify service account has Editor access to sheet
- Check credentials file path in config
- Ensure Google Sheets API is enabled

## Contributing

See `CONTRIBUTING.md` for contribution guidelines.

## Resources

- [Claude Code Hooks Documentation](https://docs.claude.com/en/docs/claude-code/hooks-guide)
- [Project Documentation](https://kanopi.github.io/claude-dev-insights/)
- [GitHub Repository](https://github.com/kanopi/claude-dev-insights)
