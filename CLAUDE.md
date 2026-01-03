# Claude Dev Insights - Project Context

## Project Overview

Claude Dev Insights is a comprehensive analytics and productivity plugin for Claude Code CLI. It provides automated session tracking through intelligent hooks.

## Architecture

### Core Components

1. **Hooks System** (`hooks/`)
   - **SessionStart**: Captures development environment context when sessions begin
   - **SessionEnd**: Logs comprehensive session statistics to CSV
   - **UserPromptSubmit**: Extracts ticket numbers and session topics from structured commands

2. **Configuration** (`config/`)
   - `pricing.json`: Model pricing for cost calculations

3. **Documentation** (`docs/`)
   - Built with Zensical (MkDocs-compatible)
   - Deployed to GitHub Pages at https://kanopi.github.io/claude-dev-insights/

### Data Collection

**Session CSV Format (29 fields):**
- Location: `~/.claude/session-logs/sessions.csv`
- Contains: timestamps, user info, project context, token usage, costs, tool usage, git status, ticket numbers, AI model used
- Optional sync to Google Sheets for team collaboration

**Ticket Tracking:**
- **#ticket: command** - Type `#ticket: JIRA-1234` at the start of your message to set tickets
- **Multiple tickets** - Supports multiple tickets: `#ticket: JIRA-1234 GH-567`
- **Incremental** - Add more tickets throughout session with additional `#ticket:` commands

**Session Topics:**
- **#topic: command** - Type `#topic: feat: Adding authentication` at the start of your message
- **Updateable** - Set or update the topic anytime during the session
- **Convention format** - Supports conventional commit style (feat:, fix:, refactor:, etc.)
- **CSV storage** - Topic is saved to the sessions.csv for easy reference and reporting

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
  user-prompt-submit/
    user-prompt-submit.sh  # Ticket and topic extraction
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
- Service account credentials for Google Sheets must be kept private

### Cost Calculation

Costs are calculated automatically using `config/pricing.json`, which contains pricing for:
- Claude Sonnet 4.5 (default): Input $3.00/M, Output $15.00/M, Cache read $0.30/M, Cache write $3.75/M
- Claude Opus 4.5: Input $15.00/M, Output $75.00/M
- Claude Haiku 4: Input $0.80/M, Output $4.00/M
- Claude 3.5 Sonnet variants

The session-end hook detects the model used and applies the appropriate pricing. Update `config/pricing.json` to add new models or adjust rates.

### Hook Behavior

- **SessionStart/SessionEnd**: Run automatically, output to stderr (may not be visible in console)
- **UserPromptSubmit**: Parses structured commands (#ticket:, #topic:) from user messages

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
