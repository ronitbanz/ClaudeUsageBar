#!/bin/bash
set -e

echo "Building ClaudeUsageBar..."
swift build -c release

BINARY="$(pwd)/.build/release/ClaudeUsageBar"
PLIST="$HOME/Library/LaunchAgents/com.claude.usagebar.plist"

# Stop existing instance if running
launchctl unload "$PLIST" 2>/dev/null || true

cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.usagebar</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BINARY</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

launchctl load "$PLIST"
echo "Done! ClaudeUsageBar is running — check your menu bar."
echo "Click it and log in to claude.ai the first time."
