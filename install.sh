#!/bin/bash
set -e

# CCUsage Monitor Installation Script
echo "🚀 Installing CCUsage Monitor..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This tool is only supported on macOS"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is required but not installed."
    echo "Please install Xcode Command Line Tools:"
    echo "xcode-select --install"
    exit 1
fi

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed."
    echo "Please install Node.js first:"
    echo "brew install node"
    exit 1
fi

# Check if ccusage is installed
if ! command -v npx ccusage &> /dev/null; then
    echo "📦 Installing ccusage CLI tool..."
    npm install -g ccusage@latest
fi

# Create installation directory
INSTALL_DIR="/usr/local/bin/ccusage-monitor"
echo "📁 Creating installation directory: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

# Download the main Swift file
echo "⬇️  Downloading CCUsage Monitor files..."
curl -fsSL https://raw.githubusercontent.com/joachimBrindeau/ccusage-monitor/main/main.swift -o /tmp/ccusage-monitor.swift

# Install the file
sudo cp /tmp/ccusage-monitor.swift "$INSTALL_DIR/main.swift"

# Create executable wrapper script
echo "🔧 Creating executable script..."

# Main wrapper script
sudo tee "$INSTALL_DIR/ccusage-monitor" > /dev/null << 'EOF'
#!/bin/bash
exec swift "/usr/local/bin/ccusage-monitor/main.swift" "$@"
EOF

# Make script executable
sudo chmod +x "$INSTALL_DIR/ccusage-monitor"

# Create symlink in /usr/local/bin
sudo ln -sf "$INSTALL_DIR/ccusage-monitor" /usr/local/bin/ccusage-monitor

# Set up auto-start for GUI version
echo "⚙️  Setting up auto-start..."
PLIST_PATH="$HOME/Library/LaunchAgents/com.ccusage.monitor.plist"

# Create LaunchAgent plist
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ccusage.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ccusage-monitor</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/dev/null</string>
    <key>StandardErrorPath</key>
    <string>/dev/null</string>
</dict>
</plist>
EOF

# Load the LaunchAgent
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# Clean up temp files
rm -f /tmp/ccusage-monitor.swift

echo "✅ CCUsage Monitor installed successfully!"
echo ""
echo "🎯 Usage:"
echo "  ccusage-monitor        # Start GUI menu bar monitor"
echo ""
echo "🔄 The GUI monitor is now running and will auto-start on login."
echo "📊 Look for the usage percentage in your menu bar!"
echo ""
echo "🛑 To stop auto-start:"
echo "  launchctl unload ~/Library/LaunchAgents/com.ccusage.monitor.plist"
