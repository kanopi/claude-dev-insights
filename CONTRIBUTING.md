# Contributing to Claude Dev Insights

Thank you for your interest in contributing to Claude Dev Insights! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/claude-dev-insights.git
   cd claude-dev-insights
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Prerequisites

- Claude Code CLI
- `jq` for JSON parsing
- `bats` for running tests
- Python 3 (for Google Sheets integration and docs)
- `zensical` for building documentation

Install dependencies:
```bash
# macOS
brew install jq bats-core

# Linux (Ubuntu/Debian)
apt-get install jq bats

# Python packages
pip install zensical
```

### Making Changes

1. **Write tests first** when adding new features
2. **Update documentation** for any user-facing changes
3. **Follow existing code style** in hook scripts
4. **Test locally** before pushing:
   ```bash
   # Run BATS tests
   bats tests/test-plugin.bats

   # Build documentation
   zensical build
   zensical serve  # Preview at http://localhost:8000
   ```

### Hook Development

When modifying hooks:

1. Test hooks individually:
   ```bash
   # Test with sample input
   echo '{"session_id":"test123","cwd":"'$(pwd)'"}' | bash hooks/session-start/session-start.sh
   ```

2. Check for syntax errors:
   ```bash
   bash -n hooks/session-end/session-end.sh
   ```

3. Ensure hooks are executable:
   ```bash
   chmod +x hooks/*//*.sh
   ```

### Configuration Files

When modifying `config/*.json`:

1. Validate JSON syntax:
   ```bash
   jq empty config/security-patterns.json
   ```

2. Update documentation if adding new config options

3. Add tests for new configuration validation

## Testing

### Running Tests Locally

```bash
# Run all BATS tests
bats tests/test-plugin.bats

# Run specific test
bats tests/test-plugin.bats -f "plugin manifest"

# Verbose output
bats tests/test-plugin.bats --tap
```

### Writing Tests

Add tests to `tests/test-plugin.bats`:

```bash
@test "your test description" {
  # Arrange
  expected="value"

  # Act
  result=$(your_command)

  # Assert
  [ "$result" = "$expected" ]
}
```

## Pull Request Process

1. **Update your branch** with latest main:
   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. **Run tests** and ensure they pass:
   ```bash
   bats tests/test-plugin.bats
   ```

3. **Update documentation**:
   - Update `CHANGELOG.md` with your changes
   - Update relevant docs in `docs/`
   - Update README.md if needed

4. **Commit your changes** with clear messages:
   ```bash
   git commit -m "feat: add new feature"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `test:` - Test additions or changes
   - `chore:` - Maintenance tasks

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub with:
   - Clear title describing the change
   - Description of what changed and why
   - Link to related issues (if any)
   - Screenshots (if applicable)

## Code Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Your changes will be included in the next release

## Reporting Issues

When reporting issues, please include:

- **Claude Code version**: Run `claude --version`
- **Plugin version**: Check `.claude-plugin/plugin.json`
- **Operating system**: macOS, Linux, etc.
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Relevant logs** from `~/.claude/debug/` or `~/.claude/session-logs/`

## Feature Requests

We welcome feature requests! Please:

1. Check existing issues to avoid duplicates
2. Describe the problem you're trying to solve
3. Explain your proposed solution
4. Consider if it fits the plugin's scope

## Documentation

Documentation is built with Zensical and uses MkDocs configuration:

```bash
# Build docs
zensical build

# Serve locally
zensical serve

# Check for broken links
zensical build --strict
```

### Documentation Structure

- `docs/index.md` - Homepage
- `docs/features/` - Feature documentation
- `docs/configuration/` - Configuration guides
- `docs/google-sheets/` - Google Sheets integration
- `docs/usage/` - Usage examples

## Release Process

Releases are handled by maintainers:

1. Update version in `.claude-plugin/plugin.json`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag -a v1.x.x -m "Release 1.x.x"`
4. Push tag: `git push origin v1.x.x`
5. GitHub Actions will build and deploy docs

## Questions?

- Open an issue for questions
- Check existing documentation first
- Be respectful and constructive

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment
- Follow GitHub's Community Guidelines

## License

By contributing, you agree that your contributions will be licensed under the GPL-2.0-or-later license.

---

**Thank you for contributing to Claude Dev Insights!**
