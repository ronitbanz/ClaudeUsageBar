#!/bin/bash
launchctl unload "$HOME/Library/LaunchAgents/com.claude.usagebar.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.claude.usagebar.plist"
echo "ClaudeUsageBar removed."
