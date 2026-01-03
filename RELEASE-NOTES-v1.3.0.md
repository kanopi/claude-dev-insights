# Release Notes - v1.3.0

**Release Date**: January 3, 2026

## Overview

Version 1.3.0 introduces deterministic command parsing for the UserPromptSubmit hook, replacing conversational parsing with structured commands for more predictable and reliable session tracking.

## What's New

### Deterministic Command Format

**Old conversational format (deprecated):**
```
ticket: JIRA-1234
summary: Fixing authentication bug
```

**New structured format (required):**
```
#ticket: JIRA-1234
#topic: fix: Fixing authentication bug
```

### Key Improvements

1. **Zero False Positives**
   - `#` prefix clearly distinguishes commands from conversation
   - No more accidental ticket detection in natural language
   - Predictable parsing every time

2. **56.8% Code Reduction**
   - Hook simplified from 229 to 99 lines
   - Easier to maintain and debug
   - Faster execution

3. **Cleaner Output**
   - Silent operation when no commands present
   - Minimal confirmation: `[Ticket: X | Topic: Y]`
   - No console pollution with verbose messages

4. **Better Naming**
   - Changed `summary:` to `#topic:` for clearer semantics
   - Encourages conventional commit style topics
   - More intuitive for developers

## Breaking Changes

This release includes breaking changes to the command format. Users must update their workflow to use the new structured commands.

### What Changed

| Old Format | New Format | Notes |
|------------|------------|-------|
| `ticket: JIRA-1234` | `#ticket: JIRA-1234` | Add `#` prefix |
| `summary: Description` | `#topic: Description` | Rename + add `#` prefix |
| Automatic detection | Explicit command only | No auto-detection |

### Migration Required

All users upgrading from v1.2.x must:
1. Add `#` prefix to ticket commands
2. Change `summary:` to `#topic:`
3. Use explicit `#ticket:` instead of relying on auto-detection

## New Command Reference

### Track Tickets

Set one ticket:
```
#ticket: JIRA-1234
```

Set multiple tickets:
```
#ticket: JIRA-1234 GH-567
```

Add more tickets later:
```
#ticket: JIRA-1234
# ... work on first ticket ...
#ticket: GH-567
# ... work on second ticket ...
```

Result in CSV: `JIRA-1234 GH-567`

### Describe Your Work

Set session topic:
```
#topic: feat: Adding user authentication
```

With conventional commit prefix:
```
#topic: fix: Resolving checkout bug
#topic: refactor: Optimizing database queries
#topic: docs: Updating API documentation
#topic: test: Adding integration tests
```

### Combine Commands

Set both ticket and topic:
```
#ticket: JIRA-1234 #topic: feat: Adding dark mode support
```

### Output Format

When commands are processed, you'll see minimal confirmation:
```
[Ticket: JIRA-1234 | Topic: feat: Adding dark mode support]
```

When no commands are present, the hook operates silently (no output).

## Technical Details

### Files Changed

- `hooks/user-prompt-submit/user-prompt-submit.sh`: Refactored command parsing (229 → 99 lines)
- `hooks/hooks.json`: Updated hook description
- `README.md`: Updated Quick Start examples
- `CLAUDE.md`: Updated Data Collection documentation
- `docs/features/session-analytics.md`: Comprehensive new command guide
- `docs/quick-start.md`: Updated hook description
- `tests/test-plugin.bats`: Updated 4 tests for new format
- `.claude-plugin/plugin.json`: Version bumped to 1.3.0
- `CHANGELOG.md`: Release notes and migration guide

### Test Coverage

- All 60 tests passing
- 100% test coverage maintained
- New tests for combined commands
- Tests for ticket-only and topic-only scenarios

### Performance

- Simpler parsing logic = faster execution
- Reduced code complexity = fewer potential bugs
- Deterministic parsing = zero false positives

## Installation

### New Users

```bash
claude plugin install kanopi/claude-dev-insights
```

### Existing Users (Upgrading)

```bash
# Plugin auto-updates, or force update:
claude plugin update kanopi/claude-dev-insights

# Verify version
claude plugin list | grep claude-dev-insights
# Should show: claude-dev-insights@1.3.0
```

## Migration Guide

### Step 1: Learn New Syntax

Replace old commands with new structured format:

**Before (v1.2.x):**
```
ticket: JIRA-1234
summary: Refactoring authentication
```

**After (v1.3.0):**
```
#ticket: JIRA-1234
#topic: refactor: Refactoring authentication
```

### Step 2: Update Your Workflow

1. Start sessions with ticket number:
   ```
   #ticket: JIRA-1234
   Working on authentication refactoring
   ```

2. Add session topic (optional):
   ```
   #topic: refactor: Simplifying auth flow
   ```

3. Add more tickets as you work:
   ```
   #ticket: GH-567
   Now working on the UI component
   ```

### Step 3: Verify CSV Output

Check that your sessions are logged correctly:

```bash
# View last session
tail -1 ~/.claude/session-logs/sessions.csv

# Search for ticket
grep "JIRA-1234" ~/.claude/session-logs/sessions.csv

# Search for topic
grep "refactor: Simplifying auth" ~/.claude/session-logs/sessions.csv
```

### Step 4: Update Team Documentation

If your team uses this plugin:
1. Update internal docs with new command format
2. Share this release note with team members
3. Update any scripts that parse hook output

## FAQ

### Q: Can I still use the old `ticket:` format?
**A:** No. The old conversational format is deprecated and no longer supported. You must use `#ticket:` going forward.

### Q: Will automatic ticket detection come back?
**A:** No. Automatic detection was removed intentionally to eliminate false positives. The explicit `#ticket:` command is more reliable and predictable.

### Q: Do I have to use conventional commit prefixes in topics?
**A:** No, it's optional but recommended. You can use any descriptive text for topics:
- With prefix: `#topic: feat: Adding authentication`
- Without prefix: `#topic: Adding authentication`

### Q: Can I set multiple topics?
**A:** Yes, each `#topic:` command updates the session topic. The last topic set will be saved to the CSV.

### Q: What if I forget to set a ticket?
**A:** The session will still be logged to CSV, but the `ticket_number` field will be empty. Set tickets with `#ticket:` at any point during the session.

### Q: Can I use `#ticket:` in the middle of my message?
**A:** No, `#ticket:` must appear at the start of your message. However, `#topic:` can appear anywhere after `#ticket:`.

### Q: Why the `#` prefix?
**A:** The `#` clearly marks commands as distinct from natural conversation, preventing false positives and making parsing deterministic.

### Q: Will this break my existing CSV data?
**A:** No. Existing CSV data remains intact. Only new sessions use the new command format. Historical data is unchanged.

## Known Issues

None at this time. Report issues at: https://github.com/kanopi/claude-dev-insights/issues

## Rollback Instructions

If you need to revert to v1.2.3:

```bash
claude plugin install kanopi/claude-dev-insights@1.2.3
```

## Support

- **Documentation**: https://kanopi.github.io/claude-dev-insights/
- **Issues**: https://github.com/kanopi/claude-dev-insights/issues
- **Discussions**: https://github.com/kanopi/claude-dev-insights/discussions
- **Changelog**: https://github.com/kanopi/claude-dev-insights/blob/main/CHANGELOG.md

## Credits

This release simplifies the plugin architecture for better maintainability and reliability, informed by real-world usage patterns and user feedback.

**Contributors:**
- Jim Birch <git@jimbir.ch>
- Claude Sonnet 4.5 (AI pair programmer)

## Next Steps

After upgrading:
1. Read the migration guide above
2. Test new commands in a session
3. Verify CSV output is correct
4. Update team documentation
5. Share feedback via GitHub Discussions

## Related Resources

- [Full Changelog](https://github.com/kanopi/claude-dev-insights/blob/main/CHANGELOG.md)
- [Session Analytics Guide](https://kanopi.github.io/claude-dev-insights/features/session-analytics/)
- [Quick Start Guide](https://kanopi.github.io/claude-dev-insights/quick-start/)
- [GitHub Repository](https://github.com/kanopi/claude-dev-insights)

---

Thank you for using Claude Dev Insights!
