# Configuration Overview

Claude Dev Insights can be customized through configuration files in the `config/` directory.

## Available Configuration Files

### [Pricing Configuration](pricing.md)
**File**: `config/pricing.json`

Configure AI model pricing for accurate cost tracking. Supports multiple Claude models including Sonnet, Opus, and Haiku variants.

### [Security Patterns](security-patterns.md)
**File**: `config/security-patterns.json`

Define file patterns and commands that should be blocked for security reasons.

### [Cost Thresholds](cost-thresholds.md)
**File**: `config/cost-thresholds.json`

Set budget limits and define expensive tools to guard against excessive API costs.

### [Quality Rules](quality-rules.md)
**File**: `config/quality-rules.json`

Configure linters, code quality checks, and commit message rules.

## Configuration Best Practices

1. **Version Control**: Keep configuration files in your repository
2. **Documentation**: Document any custom changes in comments
3. **Testing**: Test configuration changes in a development environment first
4. **Updates**: Keep pricing data current with Anthropic's latest rates

[Back to home](../index.md)
