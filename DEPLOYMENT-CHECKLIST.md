# Deployment Checklist - v1.3.0

## Pre-Release Validation

### Code Quality
- [x] All 60 BATS tests passing
- [x] No syntax errors in shell scripts
- [x] Hook scripts are executable
- [x] JSON configuration files valid
- [x] Documentation markdown lint clean

### Testing
- [x] Manual test: `#ticket:` command extracts tickets correctly
- [x] Manual test: `#topic:` command sets session topic
- [x] Manual test: Combined commands work: `#ticket: JIRA-1234 #topic: feat: New feature`
- [x] Manual test: Multiple tickets: `#ticket: JIRA-1234 GH-567`
- [x] Manual test: Incremental ticket additions work across session
- [x] Manual test: Silent operation when no commands present
- [x] Manual test: Output format is minimal: `[Ticket: X | Topic: Y]`

### Version Updates
- [x] CHANGELOG.md updated with v1.3.0 entry
- [ ] .claude-plugin/plugin.json version updated to 1.3.0
- [ ] Git tag created: `v1.3.0`

### Documentation Review
- [x] README.md reflects new command format
- [x] CLAUDE.md updated with new hook behavior
- [x] docs/features/session-analytics.md updated
- [x] docs/quick-start.md updated
- [x] Migration guide included in CHANGELOG.md

## Deployment Steps

### 1. Version Bump
```bash
# Update plugin.json version
jq '.version = "1.3.0"' .claude-plugin/plugin.json > temp.json && mv temp.json .claude-plugin/plugin.json

# Verify version
jq '.version' .claude-plugin/plugin.json
```

### 2. Final Testing
```bash
# Run full test suite
bats tests/test-plugin.bats

# Expected: 60 tests, 0 failures
```

### 3. Git Operations
```bash
# Ensure all changes committed
git status

# Create and push tag
git tag -a v1.3.0 -m "Release v1.3.0: Deterministic command parsing"
git push origin feature/userprompt
git push origin --tags
```

### 4. Create Pull Request
```bash
# Create PR via GitHub CLI
gh pr create \
  --title "Release v1.3.0: Deterministic UserPromptSubmit commands" \
  --body "$(cat DEPLOYMENT-CHECKLIST.md)"
```

### 5. Post-Merge
- [ ] Verify GitHub Actions CI passes
- [ ] Verify documentation deploys to GitHub Pages
- [ ] Create GitHub Release from tag
- [ ] Update marketplace listing (if applicable)

## Post-Deployment Validation

### Smoke Tests
After merging to main:

```bash
# 1. Fresh install test
rm -rf ~/.claude/plugins/cache/claude-dev-insights
claude plugin install kanopi/claude-dev-insights

# 2. Start new session
claude code .

# 3. Test new command format
#ticket: TEST-001
#topic: test: Validating v1.3.0 release

# 4. Verify CSV logging
tail -1 ~/.claude/session-logs/sessions.csv | grep "TEST-001"

# 5. Verify topic logged
tail -1 ~/.claude/session-logs/sessions.csv | grep "test: Validating"
```

### User Communication
- [ ] Update plugin documentation site
- [ ] Post release notes to GitHub Discussions
- [ ] Notify users of breaking changes via GitHub Release
- [ ] Update README badges with new version

## Rollback Plan

If critical issues discovered post-deployment:

### Immediate Rollback
```bash
# Revert to v1.2.3
git revert HEAD
git push origin main

# Update marketplace to point to v1.2.3
# Users can pin: claude plugin install kanopi/claude-dev-insights@1.2.3
```

### Issue Triage
1. Check GitHub Issues for bug reports
2. Review session logs for errors: `~/.claude/debug/`
3. Check hook execution logs for failures
4. Test in isolated environment

## Breaking Changes Communication

### User Impact
Users upgrading from v1.2.x will need to:
1. Replace `ticket:` with `#ticket:`
2. Replace `summary:` with `#topic:`
3. Stop relying on automatic ticket detection
4. Update any automation/scripts that parse hook output

### Migration Timeline
- **Immediate**: v1.3.0 released with new format
- **Week 1**: Monitor for issues, provide user support
- **Week 2**: Collect feedback on new format
- **Week 4**: Evaluate success metrics (adoption, errors, feedback)

## Success Metrics

Post-deployment tracking (30 days):

### Usage Metrics
- [ ] Track sessions using new `#ticket:` format
- [ ] Track sessions using new `#topic:` format
- [ ] Monitor CSV data quality (fewer malformed entries)
- [ ] Compare error rates vs. v1.2.3

### User Feedback
- [ ] GitHub Issues: Bug reports vs. feature requests ratio
- [ ] GitHub Discussions: Sentiment analysis
- [ ] Documentation views: Are users finding migration guide?

### Technical Metrics
- [ ] Hook execution time (should be faster with simpler parsing)
- [ ] False positive rate (should be zero with deterministic parsing)
- [ ] Test coverage maintained at 100%

## Notes

### Why This Release?
- **Problem**: Conversational parsing was error-prone and unpredictable
- **Solution**: Strict structured commands with deterministic parsing
- **Benefit**: 56.8% code reduction, zero false positives, cleaner output

### Design Decisions
1. **`#` prefix**: Prevents conflicts with natural language
2. **`topic` vs `summary`**: Better semantic meaning for session description
3. **Silent operation**: No output pollution when commands not present
4. **Minimal output**: `[Ticket: X | Topic: Y]` format for confirmation

### Known Limitations
- Commands must be typed exactly (no variations)
- `#ticket:` must be at message start (not middle)
- No automatic ticket detection (trade-off for determinism)

### Future Considerations
- Could add command aliases if users request
- Could support multiple `#topic:` updates (currently last wins)
- Could add validation for ticket format patterns
