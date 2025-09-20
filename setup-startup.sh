#!/bin/bash
set -e

INSTALL_DIR="/usr/local/bin/ccusage-monitor"
PLIST_NAME="com.ccusage.monitor.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "Setting up CCUsage Monitor to run at startup..."

# Create installation directory
sudo mkdir -p "$INSTALL_DIR"

# Copy application files
sudo cp main.swift "$INSTALL_DIR/"
sudo cp com.ccusage.monitor.plist /tmp/

# Update plist with correct path
sed "s|/usr/local/bin/ccusage-monitor/main.swift|$INSTALL_DIR/main.swift|g" /tmp/com.ccusage.monitor.plist > /tmp/updated.plist

# Install launch agent
mkdir -p "$HOME/Library/LaunchAgents"
cp /tmp/updated.plist "$PLIST_PATH"

# Load the launch agent
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "✓ CCUsage Monitor will now start automatically at login"
echo "✓ Current session started"

# Clean up
rm -f /tmp/com.ccusage.monitor.plist /tmp/updated.plist

echo ""
echo "To manually control the service:"
echo "  Stop:  launchctl unload '$PLIST_PATH'"
echo "  Start: launchctl load '$PLIST_PATH'"