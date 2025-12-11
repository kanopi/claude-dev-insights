# Pricing Configuration

Configure AI model pricing for accurate cost tracking in session analytics.

## Overview

The `config/pricing.json` file contains pricing information for different Claude AI models. The session-end hook uses this file to calculate accurate costs based on the model used in each session.

## File Location

```
config/pricing.json
```

## Configuration Format

```json
{
  "models": {
    "claude-sonnet-4-5-20250929": {
      "name": "Claude Sonnet 4.5",
      "input": 3.00,
      "output": 15.00,
      "cache_read": 0.30,
      "cache_write": 3.75
    },
    "claude-opus-4-5-20251101": {
      "name": "Claude Opus 4.5",
      "input": 15.00,
      "output": 75.00,
      "cache_read": 1.50,
      "cache_write": 18.75
    }
  },
  "default": {
    "name": "Default (Sonnet 4.5 pricing)",
    "input": 3.00,
    "output": 15.00,
    "cache_read": 0.30,
    "cache_write": 3.75
  }
}
```

## Field Descriptions

| Field | Description |
|-------|-------------|
| `models` | Object containing pricing for each model ID |
| `models[model_id].name` | Human-readable model name |
| `models[model_id].input` | Cost per million input tokens (USD) |
| `models[model_id].output` | Cost per million output tokens (USD) |
| `models[model_id].cache_read` | Cost per million cache read tokens (USD) |
| `models[model_id].cache_write` | Cost per million cache write tokens (USD) |
| `default` | Fallback pricing when model is not found |

## Included Models (January 2025)

| Model | Input | Output | Cache Read | Cache Write |
|-------|-------|--------|------------|-------------|
| Claude Sonnet 4.5 | $3.00/M | $15.00/M | $0.30/M | $3.75/M |
| Claude Opus 4.5 | $15.00/M | $75.00/M | $1.50/M | $18.75/M |
| Claude Opus 4 | $15.00/M | $75.00/M | $1.50/M | $18.75/M |
| Claude Sonnet 4 | $3.00/M | $15.00/M | $0.30/M | $3.75/M |
| Claude Haiku 4 | $0.80/M | $4.00/M | $0.08/M | $1.00/M |
| Claude 3.5 Sonnet (Oct 2024) | $3.00/M | $15.00/M | $0.30/M | $3.75/M |
| Claude 3.5 Sonnet (Jun 2024) | $3.00/M | $15.00/M | $0.30/M | $3.75/M |

## How It Works

1. **Model Detection**: The session-end hook extracts the model ID from the transcript (e.g., `claude-sonnet-4-5-20250929`)
2. **Pricing Lookup**: Looks up pricing in `config/pricing.json` using the model ID
3. **Cost Calculation**: Calculates costs using the model-specific rates:
   - Input cost = (input_tokens × input_price) / 1,000,000
   - Output cost = (output_tokens × output_price) / 1,000,000
   - Cache read cost = (cache_read_tokens × cache_read_price) / 1,000,000
   - Cache write cost = (cache_write_tokens × cache_write_price) / 1,000,000
   - Total cost = sum of all costs
4. **Fallback**: If the model isn't found, uses the `default` pricing

## Adding a New Model

To add pricing for a new model:

1. Find the exact model ID (check session transcript or CSV)
2. Get current pricing from [Anthropic Pricing](https://www.anthropic.com/pricing)
3. Add entry to `config/pricing.json`:

```json
{
  "models": {
    "new-model-id-here": {
      "name": "Model Display Name",
      "input": 0.00,
      "output": 0.00,
      "cache_read": 0.00,
      "cache_write": 0.00
    }
  }
}
```

## Updating Pricing

When Anthropic updates their pricing:

1. Update the rates in `config/pricing.json`
2. Add a note in the `notes` array with the date
3. Costs will be calculated with new rates for all future sessions

**Note**: Existing session data in the CSV is not recalculated. Historical costs remain as originally calculated.

## Viewing Model Usage

To see which models are being used in your sessions:

```bash
# View unique models used
cut -d, -f28 ~/.claude/session-logs/sessions.csv | sort | uniq -c

# Cost by model
awk -F, 'NR>1 {cost[$28]+=$21} END {for(m in cost) print m": $"cost[m]}' ~/.claude/session-logs/sessions.csv
```

## Troubleshooting

### Costs seem incorrect

1. Check that the model ID in your CSV matches an entry in `config/pricing.json`
2. Verify pricing matches current Anthropic rates
3. Check that the pricing.json file has valid JSON syntax

### Model not found

If a model isn't in the config file, the default pricing is used. Add the model to `config/pricing.json` to get accurate costs.

[Back to Configuration Overview](overview.md)
