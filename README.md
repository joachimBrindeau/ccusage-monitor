# CCUsage Monitor - Claude API Usage Tracker for macOS Menu Bar

[![GitHub release](https://img.shields.io/github/v/release/joachimBrindeau/ccusage-monitor)](https://github.com/joachimBrindeau/ccusage-monitor/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos)

> **Monitor your Claude API usage and reset time directly in your macOS menu bar**

Built on the trusted [ccusage CLI tool](https://github.com/evanmschultz/ccusage), this ultra-lightweight **181-line Swift app** displays your **Claude usage percentage** and **reset countdown** without cluttering your workflow.

![CCUsage Monitor Demo](https://img.shields.io/badge/Menu%20Bar%20Display-75%25%20%7C%202h%2015m-success?style=for-the-badge&logo=apple)

## 🚀 Claude Usage Monitoring Made Simple

Transform your **ccusage** terminal data for your **current active billing block** into a persistent **menu bar indicator**:

- ✅ **Configurable display metrics** - choose what to show in menu bar
- 📊 **Available metrics**: percentage, time, tokens, money (with used/left toggle)
- 🎛️ **Smart toggles** - money option auto-disables when inappropriate
- ⏰ **Current block tracking** - monitors your active Claude billing period
- 🔄 **Auto-refresh every 30 seconds** - always current data
- ⌨️ **Right-click menu** to toggle display options and refresh
- 🏃‍♂️ **Auto-start on login** - enabled by default
- 🪶 **Ultra-minimal** - just 181 lines of Swift code

## 📦 Installation - Claude API Usage Monitor Setup

### 🍺 Homebrew Installation (Recommended)

```bash
# One-command install for both ccusage and menu bar monitor
brew tap joachimbrindeau/ccusage-monitor
brew install ccusage-monitor

# Launch the Claude usage monitor (auto-start enabled by default)
ccusage-monitor
```

### 📋 Manual Installation (Auto-start included)

```bash
# One-command install with automatic startup
git clone https://github.com/joachimBrindeau/ccusage-monitor.git
cd ccusage-monitor
./install
```

<details>
<summary>What the installer does</summary>

1. **Checks dependencies** - Swift, Node.js, ccusage
2. **Installs ccusage** if missing (`npm install -g ccusage`)
3. **Tests ccusage connection** to ensure Claude API access
4. **Installs monitor** to `~/.local/share/ccusage-monitor/`
5. **Creates launcher** at `~/.local/bin/ccusage-monitor`
6. **Sets up auto-start** (Launch Agent) - enabled by default
7. **Starts immediately** in menu bar

</details>

### ⚡ Direct Run (Development)

```bash
# Run directly from source (requires ccusage installed)
swift bin/main.swift
```

## 🔧 How Claude Usage Monitoring Works

| Step | Process | Description |
|------|---------|-------------|
| 1️⃣ | **CCUsage CLI** | Fetches your Claude API usage data from Anthropic |
| 2️⃣ | **JSON Parsing** | Monitor parses `ccusage blocks --active --json` output |
| 3️⃣ | **Menu Bar Display** | Shows "75% \| 2h 15m" format in your status bar |
| 4️⃣ | **Auto-Refresh** | Updates every 30 seconds automatically |

## ⚙️ CCUsage Monitor Configuration

### 🚀 Auto-Start Control (Enabled by Default)

```bash
# Monitor commands
ccusage-monitor                    # Start monitor
pkill -f 'swift main.swift'       # Stop monitor

# Auto-start control
launchctl load ~/Library/LaunchAgents/com.ccusage.monitor.plist     # Enable auto-start
launchctl unload ~/Library/LaunchAgents/com.ccusage.monitor.plist   # Disable auto-start
```

### 🎯 Menu Bar Controls for Claude Usage

| Action | Shortcut | Function |
|--------|----------|----------|
| **Refresh Claude Data** | `⌘R` | Instantly update current block stats |
| **Show Percentage** | ✓/✗ | Toggle percentage display (used or left) |
| **Show Time** | ✓/✗ | Toggle time display (elapsed or remaining) |
| **Show Tokens** | ✓/✗ | Toggle token display (used or left) |
| **Show Money** | ✓/✗ | Toggle cost display (used only) |
| **Toggle Used/Left** | - | Switch between used vs remaining metrics |
| **Quit Monitor** | `⌘Q` | Stop Claude usage tracking |

**Default display**: `92% | 3h 45m` (percentage used and time elapsed)

## 💡 Claude API Usage Monitoring Benefits

### 👨‍💻 For Developers Using Claude API
- ✅ **Prevent API limit exceeded errors** during development
- ✅ **Track token consumption** in real-time while coding
- ✅ **Monitor Claude billing cycles** for budget management
- ✅ **Optimize prompt efficiency** based on usage patterns

### 🔬 For Researchers and Content Creators
- ✅ **Claude Pro subscription monitoring** - track monthly limits
- ✅ **Research budget management** - never exceed allocations
- ✅ **Content planning** based on remaining Claude capacity
- ✅ **Team coordination** for shared Claude usage

### 🏢 For Enterprise Teams Using Claude
- ✅ **Claude Enterprise usage tracking** across team members
- ✅ **Cost optimization** for Claude API consumption
- ✅ **Workflow planning** around Claude reset cycles
- ✅ **Resource allocation** based on real usage data

## 🛠️ Technical Implementation

<details>
<summary>Technical details for developers</summary>

### Architecture
- **Language**: Swift 5.5+ with Cocoa framework
- **Dependencies**: ccusage CLI tool only
- **Process**: Spawns `npx ccusage` subprocess every 30 seconds
- **UI**: Native macOS status bar item (NSStatusItem)
- **Startup**: macOS Launch Agent (plist-based)

### Code Structure
```swift
// Ultra-minimal 181-line implementation
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var options = ["percentage": true, "timeLeft": true, "tokens": false, "money": false]
    private var showUsed = true
}
```

### Data Flow
1. `Process()` executes `npx ccusage blocks --active --json`
2. `JSONSerialization` parses response
3. Extract `totalTokens`, `projection.totalTokens`, `projection.remainingMinutes`
4. Calculate percentage and format time display
5. Update `NSStatusItem.button.title`

</details>

## 📋 System Requirements for Claude Monitoring

| Requirement | Version | Purpose |
|-------------|---------|---------|
| **macOS** | 10.15+ (Catalina) | Native status bar support |
| **Node.js** | Any recent version | Powers ccusage CLI tool |
| **Swift** | 5.5+ | Included with Xcode Command Line Tools |
| **ccusage** | Latest | Core Claude usage data provider |

## 🐛 Troubleshooting Claude Usage Monitor

<details>
<summary>Common issues and solutions</summary>

### ❌ "No data" displayed in menu bar

**Cause**: CCUsage CLI not working properly

**Solutions**:
```bash
# Check ccusage installation
npm list -g ccusage

# Test ccusage directly
npx ccusage blocks --active --json

# Reinstall if needed
npm install -g ccusage@latest
```

### ❌ Monitor app won't start

**Cause**: Swift or system requirements not met

**Solutions**:
```bash
# Verify Swift installation
swift --version

# Install Xcode Command Line Tools if missing
xcode-select --install

# Try running directly
cd ccusage-monitor && swift main.swift
```

### ❌ Auto-startup not working

**Cause**: Launch Agent configuration issues

**Solutions**:
```bash
# Check launch agent status
launchctl list | grep ccusage

# Reload launch agent
launchctl unload ~/Library/LaunchAgents/com.ccusage.monitor.plist
launchctl load ~/Library/LaunchAgents/com.ccusage.monitor.plist

# Verify permissions
ls -la ~/Library/LaunchAgents/com.ccusage.monitor.plist
```

</details>

---

## 📞 Support & Contributing

### 🐛 Found an Issue?
[Open an issue](https://github.com/joachimBrindeau/ccusage-monitor/issues/new) on GitHub with:
- macOS version
- ccusage version (`npm list -g ccusage`)
- Error message or expected vs actual behavior

### 🚀 Want to Contribute?
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### ⭐ Star This Repository
If CCUsage Monitor helps you track your Claude API usage, please give it a star! ⭐

---

<div align="center">

**Built with ❤️ for the Claude API community**

[🏠 Homepage](https://github.com/joachimBrindeau/ccusage-monitor) • [📋 Issues](https://github.com/joachimBrindeau/ccusage-monitor/issues) • [🚀 Releases](https://github.com/joachimBrindeau/ccusage-monitor/releases)

</div>