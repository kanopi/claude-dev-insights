# Google Sheets Setup

Automatically sync your session data to Google Sheets for cloud backup and team collaboration.

## Benefits

- ☁️ **Cloud backup** - Your data is safe in the cloud
- 👥 **Team sharing** - Share insights with your team
- 📊 **Easy visualization** - Built-in charts and pivot tables
- 📱 **Access anywhere** - View on any device
- 🔄 **Real-time sync** - Data updates automatically after each session

## Prerequisites

1. **Python 3** installed on your system
2. **pip** (Python package manager)
3. **Google Cloud account** (free tier works fine)

## Setup Steps

### 1. Install Python Packages

```bash
pip3 install gspread oauth2client
```

### 2. Create Google Cloud Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or use existing)
3. Go to **APIs & Services** → **Library**
4. Search for "Google Sheets API" → Click **Enable**
5. Go to **APIs & Services** → **Credentials**
6. Click **Create Credentials** → **Service Account**
7. Name it "claude-code-logger" → Click **Create and Continue** → **Done**
8. Click on the service account name
9. Go to **Keys** tab → **Add Key** → **Create new key** → **JSON** → **Create**
10. Save the downloaded JSON file (e.g., `~/.claude/service-account-key.json`)

**Important:** Keep this credentials file private! Add it to `.gitignore` if in a repository.

### 3. Create and Share Google Sheet

1. Go to [Google Sheets](https://sheets.google.com/)
2. Create a new blank spreadsheet
3. Name it "Claude Code Sessions" (or whatever you prefer)
4. Click the **Share** button
5. Open your service account JSON file and find the `client_email` field
6. Copy that email address (looks like: `claude-code-logger@PROJECT-ID.iam.gserviceaccount.com`)
7. Paste it in the share dialog and give it **Editor** access
8. Uncheck "Notify people" → Click **Share**

### 4. Run Interactive Setup

```bash
# If installed as plugin
python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --setup

# If installed directly in project
python3 $CLAUDE_PROJECT_DIR/.claude/hooks/session-end/sync-to-google-sheets.py --setup
```

You'll be prompted for:
- **Service account JSON file path** (e.g., `~/.claude/service-account-key.json`)
- **Google Sheet URL** (copy from browser address bar)
- **Worksheet name** (default: `Sheet1`)

### 5. Test the Connection

```bash
# If installed as plugin
python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --test

# If installed directly in project
python3 $CLAUDE_PROJECT_DIR/.claude/hooks/session-end/sync-to-google-sheets.py --test
```

You should see: `✅ Successfully connected to: Claude Code Sessions`

Once configured, data syncs automatically after each session!

## Disabling Google Sheets Sync

If you want to stop syncing to Google Sheets:

```bash
# If installed as plugin
python3 ~/.claude/plugins/cache/claude-dev-insights/hooks/session-end/sync-to-google-sheets.py --disable

# If installed directly in project
python3 $CLAUDE_PROJECT_DIR/.claude/hooks/session-end/sync-to-google-sheets.py --disable
```

This will remove the configuration file but keep your CSV data intact.

## Troubleshooting

### Permission Errors

If you see permission errors:
- Verify the service account email has **Editor** access to the sheet
- Check that you shared the sheet with the exact email from `client_email` in the JSON

### Connection Errors

If you see connection errors:
- Verify the Google Sheets API is enabled in Google Cloud Console
- Check that the service account JSON file path is correct
- Ensure your service account key hasn't been deleted or expired

### Missing Dependencies

If Python packages are missing:
```bash
pip3 install --upgrade gspread oauth2client
```

## Security Best Practices

1. **Protect credentials** - Keep service account keys private
2. **Set permissions** - Only share sheets with trusted team members
3. **Use dedicated account** - Create service account specifically for this purpose
4. **Rotate keys** - Regularly update service account keys (every 90 days recommended)
5. **Monitor access** - Review sheet access permissions periodically

## Advanced Usage

See [Google Sheets Usage Guide](usage.md) for tips on:
- Creating dashboards and visualizations
- Setting up automated reports
- Sharing with team members
- Exporting data

[Back to home](../index.md)
