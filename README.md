# CCUsage Monitor

**A simple macOS menu bar app that shows your Claude API usage at a glance.**

Built on top of the popular [ccusage CLI tool](https://github.com/evanmschultz/ccusage), this lightweight app adds a **46-line Swift menu bar indicator** so you can monitor your **Claude usage** and **reset time** without opening a terminal.

![Menu Bar Preview](https://img.shields.io/badge/Menu%20Bar-75%25%20%7C%202h%2015m-blue)

## What It Does

CCUsage Monitor takes the **ccusage** command-line data and displays it in your macOS menu bar:

- Shows **usage percentage** and **time until reset** (e.g., "75% | 2h 15m")
- Updates every 30 seconds automatically
- Right-click to refresh manually or quit
- Runs on startup (optional)

**That's it.** No complex features, no bloat - just your Claude usage always visible.

## Quick Start

### Option 1: Homebrew (Easiest)

```bash
# Install both ccusage and the menu bar monitor
brew tap joachimbrindeau/ccusage-monitor
brew install ccusage-monitor
ccusage-monitor
```

### Option 2: Manual Install

```bash
# First install ccusage if you don't have it
npm install -g ccusage

# Then clone and run the monitor
git clone https://github.com/joachimBrindeau/ccusage-monitor.git
cd ccusage-monitor
./install.sh
```

## How It Works

1. **ccusage** fetches your Claude API usage data
2. **CCUsage Monitor** parses that JSON and displays it in your menu bar
3. Updates happen automatically every 30 seconds

The app simply runs `npx ccusage blocks --active --json` and shows the results visually.

## Features

- **Real-time Claude API usage tracking**
- **Claude reset time countdown**
- **Ultra-lightweight** - just 46 lines of Swift code
- **ccusage integration** - built on the trusted ccusage CLI
- **Auto-startup** option for continuous monitoring
- **Manual refresh** with ⌘R hotkey

## Setup Auto-Start (Optional)

To have the monitor start automatically when you login:

```bash
# After installation, run this once
ccusage-monitor-setup-startup
```

## Requirements

- **macOS 10.15+** (Catalina or later)
- **Node.js** (for ccusage)
- **Swift** (comes with Xcode Command Line Tools)

## Why Use This?

If you're already using **ccusage** to track your Claude API usage, this simply adds a **visual indicator** so you don't have to run terminal commands constantly.

Perfect for:
- **Developers** building with Claude API
- **Researchers** managing token budgets
- **Content creators** tracking Claude Pro limits
- **Teams** monitoring Claude usage costs

## Technical Details

- **46 lines of Swift** - ultra-minimal implementation
- **No dependencies** except ccusage (which you probably already have)
- **JSON parsing** of ccusage output
- **Background updates** every 30 seconds
- **Launch Agent** support for auto-start

## Troubleshooting

**"No data" showing?**
- Make sure `ccusage` is installed: `npm install -g ccusage`
- Verify ccusage works: `npx ccusage blocks --active --json`

**App not starting?**
- Check Swift is available: `swift --version`
- Try manual start: `swift main.swift`

## Keywords

**ccusage**, **Claude API usage**, **Claude reset time**, **Claude token limits**, **Claude usage tracking**, **Claude API monitor**, **macOS menu bar**, **Claude billing**, **Anthropic API**, **Claude Pro limits**, **token consumption**, **usage dashboard**, **API monitoring**, **Claude analytics**

## Usage

- **Menu bar display**: Shows percentage used and time remaining (e.g., "75% | 2h 15m")
- **Right-click menu**:
  - *Refresh* (⌘R): Manually update usage data
  - *Quit* (⌘Q): Exit the application

## Project Structure

```
ccusage-monitor/
└── main.swift    # Complete application (52 lines)
```

## Technical Details

Built with modern Swift patterns:
- Clean AppDelegate architecture
- Efficient JSON parsing
- Background process execution
- Responsive UI updates

The monitor calls `npx ccusage blocks --active --json` to fetch usage data and parses the response for display.

## Contributing

Pull requests welcome. Please ensure code maintains the minimal, clean architecture.

## License

MIT License - see LICENSE file for details.