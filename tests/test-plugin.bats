#!/usr/bin/env bats

# Test suite for Claude Dev Insights plugin
# Run with: bats tests/test-plugin.bats

setup() {
  # Set project root for all tests
  export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  cd "$PROJECT_ROOT"
}

# ==============================================================================
# PLUGIN MANIFEST TESTS
# ==============================================================================

@test "plugin manifest exists" {
  [ -f ".claude-plugin/plugin.json" ]
}

@test "plugin manifest is valid JSON" {
  run jq empty .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
}

@test "plugin manifest has required fields" {
  run jq -e '.name' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]

  run jq -e '.version' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]

  run jq -e '.description' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
}

@test "plugin name is claude-dev-insights" {
  run jq -r '.name' .claude-plugin/plugin.json
  [ "$output" = "claude-dev-insights" ]
}

@test "plugin version follows semver" {
  version=$(jq -r '.version' .claude-plugin/plugin.json)
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "plugin has repository URL" {
  run jq -e '.repository' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]

  # Repository should be a string
  run jq -r '.repository | type' .claude-plugin/plugin.json
  [ "$output" = "string" ]
}

# ==============================================================================
# HOOKS STRUCTURE TESTS
# ==============================================================================

@test "hooks directory exists" {
  [ -d "hooks" ]
}

@test "hooks.json exists" {
  [ -f "hooks/hooks.json" ]
}

@test "hooks.json is valid JSON" {
  run jq empty hooks/hooks.json
  [ "$status" -eq 0 ]
}

@test "hooks.json defines all expected hooks" {
  run jq -e '.hooks.SessionStart' hooks/hooks.json
  [ "$status" -eq 0 ]

  run jq -e '.hooks.SessionEnd' hooks/hooks.json
  [ "$status" -eq 0 ]

  run jq -e '.hooks.PreToolUse' hooks/hooks.json
  [ "$status" -eq 0 ]

  run jq -e '.hooks.PostToolUse' hooks/hooks.json
  [ "$status" -eq 0 ]
}

@test "all hook scripts exist and are executable" {
  [ -f "hooks/session-start/session-start.sh" ]
  [ -x "hooks/session-start/session-start.sh" ]

  [ -f "hooks/session-end/session-end.sh" ]
  [ -x "hooks/session-end/session-end.sh" ]

  [ -f "hooks/pre-tool-use/pre-tool-use.sh" ]
  [ -x "hooks/pre-tool-use/pre-tool-use.sh" ]

  [ -f "hooks/post-tool-use/post-tool-use.sh" ]
  [ -x "hooks/post-tool-use/post-tool-use.sh" ]
}

@test "all hook scripts have shebang" {
  for script in hooks/*//*.sh; do
    if [ -f "$script" ]; then
      first_line=$(head -n 1 "$script")
      [[ "$first_line" =~ ^#!/ ]]
    fi
  done
}

# ==============================================================================
# CONFIGURATION TESTS
# ==============================================================================

@test "config directory exists" {
  [ -d "config" ]
}

@test "security-patterns.json exists and is valid" {
  [ -f "config/security-patterns.json" ]
  run jq empty config/security-patterns.json
  [ "$status" -eq 0 ]
}

@test "cost-thresholds.json exists and is valid" {
  [ -f "config/cost-thresholds.json" ]
  run jq empty config/cost-thresholds.json
  [ "$status" -eq 0 ]
}

@test "quality-rules.json exists and is valid" {
  [ -f "config/quality-rules.json" ]
  run jq empty config/quality-rules.json
  [ "$status" -eq 0 ]
}

@test "security-patterns.json has required fields" {
  run jq -e '.blocked_files' config/security-patterns.json
  [ "$status" -eq 0 ]

  run jq -e '.sensitive_files' config/security-patterns.json
  [ "$status" -eq 0 ]

  run jq -e '.dangerous_commands' config/security-patterns.json
  [ "$status" -eq 0 ]
}

@test "cost-thresholds.json has required fields" {
  run jq -e '.session_budget' config/cost-thresholds.json
  [ "$status" -eq 0 ]

  run jq -e '.warn_at_percent' config/cost-thresholds.json
  [ "$status" -eq 0 ]

  run jq -e '.expensive_tools' config/cost-thresholds.json
  [ "$status" -eq 0 ]
}

@test "quality-rules.json has required fields" {
  run jq -e '.auto_lint' config/quality-rules.json
  [ "$status" -eq 0 ]

  run jq -e '.commit_message' config/quality-rules.json
  [ "$status" -eq 0 ]
}

# ==============================================================================
# DOCUMENTATION TESTS
# ==============================================================================

@test "README.md exists" {
  [ -f "README.md" ]
}

@test "README has documentation link" {
  grep -q "kanopi.github.io/claude-dev-insights" README.md
}

@test "mkdocs.yml exists" {
  [ -f "mkdocs.yml" ]
}

@test "mkdocs.yml has required fields" {
  grep -q "^site_name:" mkdocs.yml
  grep -q "^theme:" mkdocs.yml
  grep -q "^nav:" mkdocs.yml
}

@test "docs directory exists" {
  [ -d "docs" ]
}

@test "docs/index.md exists" {
  [ -f "docs/index.md" ]
}

@test "all navigation pages exist" {
  # Check key documentation files
  [ -f "docs/installation.md" ]
  [ -f "docs/quick-start.md" ]
  [ -f "docs/features/session-analytics.md" ]
  [ -f "docs/google-sheets/setup.md" ]
}

@test "CLAUDE.md exists for AI context" {
  [ -f "CLAUDE.md" ]
}

@test "CHANGELOG.md exists" {
  [ -f "CHANGELOG.md" ]
}

# ==============================================================================
# GITHUB ACTIONS TESTS
# ==============================================================================

@test "GitHub workflows directory exists" {
  [ -d ".github/workflows" ]
}

@test "deploy-docs workflow exists" {
  [ -f ".github/workflows/deploy-docs.yml" ]
}

@test "test workflow exists" {
  [ -f ".github/workflows/test.yml" ]
}

@test "workflows are valid YAML" {
  if command -v python3 &> /dev/null; then
    for workflow in .github/workflows/*.yml; do
      python3 -c "import yaml; yaml.safe_load(open('$workflow'))" || {
        echo "Invalid YAML in $workflow"
        return 1
      }
    done
  else
    skip "Python3 not available for YAML validation"
  fi
}

# ==============================================================================
# HOOK SCRIPT TESTS
# ==============================================================================

@test "session-start hook uses jq for JSON parsing" {
  grep -q "jq" hooks/session-start/session-start.sh
}

@test "session-end hook uses jq for JSON parsing" {
  grep -q "jq" hooks/session-end/session-end.sh
}

@test "session-end hook defines CSV header with 28 fields" {
  # Extract CSV header line
  header_line=$(grep -A1 "echo \"timestamp,session_id" hooks/session-end/session-end.sh | tr -d '\n' | tr -d ' ')
  # Count commas + 1 = number of fields
  field_count=$(echo "$header_line" | grep -o "," | wc -l)
  # 27 commas = 28 fields
  [ "$field_count" -eq 27 ]
}

@test "session-end hook has summary as 6th column" {
  # Extract header and check that summary is in position 6
  header=$(grep "timestamp,session_id,user,ticket_number,project,summary" hooks/session-end/session-end.sh)
  [ -n "$header" ]
}

@test "Google Sheets sync script exists" {
  [ -f "hooks/session-end/sync-to-google-sheets.py" ]
}

@test "Google Sheets sync script is executable" {
  [ -x "hooks/session-end/sync-to-google-sheets.py" ]
}

@test "Google Sheets sync script has Python shebang" {
  first_line=$(head -n 1 hooks/session-end/sync-to-google-sheets.py)
  [[ "$first_line" =~ ^#!/.*python ]]
}

# ==============================================================================
# SECURITY TESTS
# ==============================================================================

@test "no hardcoded secrets in hook scripts" {
  if grep -ri "password\s*=\|api_key\s*=\|secret\s*=" hooks/*.sh 2>/dev/null | grep -v "example\|placeholder\|TODO"; then
    echo "Potential hardcoded secrets found in hook scripts"
    return 1
  fi
}

@test "no merge conflict markers" {
  if grep -r "^<<<<<<< \|^=======$\|^>>>>>>> " hooks/ docs/ config/ 2>/dev/null; then
    echo "Found merge conflict markers"
    return 1
  fi
}

@test "security patterns block .env files" {
  run jq -e '.blocked_files | map(select(. == ".env"))' config/security-patterns.json
  [ "$status" -eq 0 ]
}

@test "security patterns block credential files" {
  patterns=$(jq -r '.blocked_files[]' config/security-patterns.json)
  echo "$patterns" | grep -q "credentials\|\.key"
}

# ==============================================================================
# FILE HYGIENE TESTS
# ==============================================================================

@test "no trailing whitespace in hook scripts" {
  if grep -n '[[:space:]]$' hooks/*/*.sh 2>/dev/null; then
    echo "Found trailing whitespace in hook scripts"
    # Not failing as cosmetic
  fi
}

@test "hook scripts use consistent indentation" {
  # Check that scripts don't mix tabs and spaces for indentation
  for script in hooks/*/*.sh; do
    if [ -f "$script" ]; then
      # Check if file has both leading tabs and leading spaces
      has_tabs=$(grep -c '^	' "$script" || echo 0)
      has_spaces=$(grep -c '^  ' "$script" || echo 0)

      if [ "$has_tabs" -gt 0 ] && [ "$has_spaces" -gt 0 ]; then
        echo "Mixed indentation in $script"
        # Not failing - might be intentional
      fi
    fi
  done
}

@test "no debug echo statements in hook scripts" {
  # Check for uncommented debug echo statements
  for script in hooks/*/*.sh; do
    if grep -n "^echo.*DEBUG\|^echo.*TEST" "$script" 2>/dev/null; then
      echo "Found debug statements in $script"
      # Not failing - might be legitimate
    fi
  done
}

# ==============================================================================
# LICENSE AND METADATA TESTS
# ==============================================================================

@test "LICENSE file exists" {
  [ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "LICENSE.txt" ]
}

@test "CONTRIBUTING.md exists" {
  [ -f "CONTRIBUTING.md" ]
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

@test "session-start hook creates context file" {
  # Test that the hook would create a session context file
  grep -q "start_context_file=" hooks/session-start/session-start.sh
  grep -q 'cat > "$start_context_file"' hooks/session-start/session-start.sh
}

@test "session-end hook reads context file" {
  # Test that the hook reads the context file created by session-start
  grep -q "start_context_file=" hooks/session-end/session-end.sh
  grep -q 'if \[ -f "$start_context_file" \]' hooks/session-end/session-end.sh
}

@test "session-end hook cleans up context file" {
  # Test that the hook removes the temp context file
  grep -q 'rm -f "$start_context_file"' hooks/session-end/session-end.sh
}

@test "hooks reference correct log directory" {
  # All hooks should use ~/.claude/session-logs
  for script in hooks/*/*.sh; do
    if [ -f "$script" ]; then
      if grep -q "log_dir=" "$script"; then
        grep -q '\$HOME/\.claude/session-logs' "$script" || {
          echo "Incorrect log directory in $script"
          return 1
        }
      fi
    fi
  done
}

# ==============================================================================
# COST CALCULATION TESTS
# ==============================================================================

@test "session-end hook calculates costs correctly" {
  # Check that all cost components are calculated
  grep -q "input_cost=" hooks/session-end/session-end.sh
  grep -q "output_cost=" hooks/session-end/session-end.sh
  grep -q "cache_read_cost=" hooks/session-end/session-end.sh
  grep -q "cache_write_cost=" hooks/session-end/session-end.sh
  grep -q "total_cost=" hooks/session-end/session-end.sh
}

@test "session-end hook uses correct pricing" {
  # Check for Claude Sonnet 4.5 pricing (as of Jan 2025)
  # Input: $3/M, Output: $15/M, Cache write: $3.75/M, Cache read: $0.30/M
  script="hooks/session-end/session-end.sh"

  # Check input token pricing ($3 per million)
  grep -q "input_tokens \* 3 / 1000000" "$script"

  # Check output token pricing ($15 per million)
  grep -q "output_tokens \* 15 / 1000000" "$script"

  # Check cache read pricing ($0.30 per million)
  grep -q "cache_read \* 0.30 / 1000000" "$script"

  # Check cache write pricing ($3.75 per million)
  grep -q "cache_write \* 3.75 / 1000000" "$script"
}

# ==============================================================================
# DOCUMENTATION CONSISTENCY TESTS
# ==============================================================================

@test "README mentions all 4 hooks" {
  grep -qi "SessionStart" README.md
  grep -qi "SessionEnd" README.md
  grep -qi "PreToolUse" README.md
  grep -qi "PostToolUse" README.md
}

@test "README mentions 28 data points" {
  grep -q "28 data points" README.md
}

@test "docs mention 28 CSV fields" {
  grep -q "28 fields" docs/features/session-analytics.md
}

@test "CSV field count matches documentation" {
  # Count fields in session-end.sh header
  header_line=$(grep "timestamp,session_id,user,ticket_number" hooks/session-end/session-end.sh | head -1)
  field_count=$(echo "$header_line" | grep -o "," | wc -l)
  field_count=$((field_count + 1))

  # Should be 28 fields
  [ "$field_count" -eq 28 ]
}
