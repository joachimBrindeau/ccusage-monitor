class CcusageMonitor < Formula
  desc "Lightweight macOS menu bar monitor for Claude API usage"
  homepage "https://github.com/joachimbrindeau/ccusage-monitor"
  url "https://github.com/joachimbrindeau/ccusage-monitor/archive/v1.0.0.tar.gz"
  sha256 "b68f03979f54cef0eeed1572dc60bd026f7ed3c02c71f76a529b6f632a2fb905"
  license "MIT"
  version "1.0.0"

  depends_on "swift"
  depends_on "node"

  def install
    # Install Node.js dependency
    system "npm", "install", "-g", "ccusage"

    # Install Swift source to lib directory
    lib.mkpath
    (lib/"ccusage-monitor").mkpath
    (lib/"ccusage-monitor").install "main.swift"

    # Create launcher script
    (bin/"ccusage-monitor").write <<~EOS
      #!/bin/bash
      cd "#{lib}/ccusage-monitor"
      nohup swift main.swift > /dev/null 2>&1 &
      echo "CCUsage Monitor started in menu bar"
    EOS

    # Create startup setup script
    (bin/"ccusage-monitor-setup-startup").write <<~EOS
      #!/bin/bash
      PLIST_PATH="$HOME/Library/LaunchAgents/com.ccusage.monitor.plist"

      mkdir -p "$HOME/Library/LaunchAgents"

      cat > "$PLIST_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ccusage.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>#{bin}/ccusage-monitor</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/dev/null</string>
    <key>StandardErrorPath</key>
    <string>/dev/null</string>
</dict>
</plist>
EOF

      launchctl unload "$PLIST_PATH" 2>/dev/null || true
      launchctl load "$PLIST_PATH"

      echo "✓ CCUsage Monitor will now start automatically at login"
    EOS

    chmod 0755, bin/"ccusage-monitor"
    chmod 0755, bin/"ccusage-monitor-setup-startup"
  end

  def caveats
    <<~EOS
      To start CCUsage Monitor:
        ccusage-monitor

      To setup automatic startup at login:
        ccusage-monitor-setup-startup

      To stop the monitor:
        pkill -f "swift main.swift"
    EOS
  end

  test do
    assert_predicate lib/"ccusage-monitor/main.swift", :exist?
  end
end