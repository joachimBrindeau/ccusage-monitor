# CCUsage Monitor - Claude API Usage Tracker for macOS

Monitor your **Claude API usage**, **Claude reset time**, and **Claude token consumption** directly in your macOS menu bar. Track **ccusage**, **Claude billing cycles**, and **Anthropic API limits** with real-time updates.

## Claude Usage Monitoring Features

- **Real-time Claude API usage tracking** - Monitor your Claude token consumption live
- **Claude reset time countdown** - See exactly when your Claude usage resets
- **CCUsage integration** - Works seamlessly with the popular ccusage npm package
- **Claude billing cycle monitoring** - Track usage across Claude's monthly billing periods
- **Anthropic API limit tracking** - Never exceed your Claude API limits again
- **Claude token percentage display** - Visual representation of Claude usage vs limits
- **Claude usage alerts** - Menu bar notifications for Claude API consumption
- **Claude API dashboard** - Quick access to Claude usage statistics
- **Minimal 47-line Swift implementation** - Lightweight Claude usage monitor
- **Auto-refresh Claude data** every 30 seconds
- **Claude startup monitoring** - Automatically starts monitoring Claude usage on login

## Claude Usage Tracking Benefits

Perfect for developers, researchers, and businesses who need to:
- Monitor **Claude API costs** and **Claude billing**
- Track **Claude token limits** and **Claude reset cycles**
- Optimize **Claude usage patterns** and **Claude API efficiency**
- Prevent **Claude overage charges** and **Claude API limit exceeded** errors
- Manage **Claude Pro subscription** usage and **Claude API quotas**
- Monitor **Claude Sonnet**, **Claude Haiku**, and **Claude Opus** token consumption
- Track **Claude conversation limits** and **Claude message caps**

## Requirements for Claude Usage Monitoring

- macOS 10.15+ (Catalina or later) for Claude usage tracking
- Swift command line tools for Claude monitor compilation
- Node.js with **ccusage package** for Claude API data fetching
- Active **Claude API access** or **Claude Pro subscription**

## Installation - Claude Usage Monitor Setup

### Option 1: Homebrew Installation (Recommended for Claude Monitoring)

```bash
# Install Claude usage monitor via Homebrew
brew tap joachimbrindeau/ccusage-monitor
brew install ccusage-monitor
ccusage-monitor
ccusage-monitor-setup-startup  # Auto-start Claude monitoring on login
```

### Option 2: Manual Claude Monitor Installation

```bash
# Clone Claude usage monitor repository
git clone https://github.com/joachimbrindeau/ccusage-monitor.git
cd ccusage-monitor

# Install Claude usage tracking dependencies
./install.sh

# Setup automatic Claude monitoring on startup (optional)
./setup-startup.sh
```

### Option 3: Direct Claude Usage Tracking

```bash
# Install ccusage for Claude API data
npm install -g ccusage

# Run Claude usage monitor directly
swift main.swift
```

## Claude Usage Monitor Interface

The **Claude usage tracker** appears in your macOS menu bar displaying:

- **Claude usage percentage** (e.g., "75%" of your Claude API limit used)
- **Claude reset time** (e.g., "2h 15m" until Claude usage resets)
- **Right-click menu** for Claude usage options:
  - **Refresh Claude Data** (⌘R) - Update Claude usage statistics immediately
  - **Quit Claude Monitor** (⌘Q) - Stop Claude usage tracking

## Claude API Integration

Works with popular **Claude usage tracking tools**:
- **ccusage npm package** - Primary Claude usage data source
- **Claude API official endpoints** - Direct Anthropic API integration
- **Claude Pro dashboard data** - Subscription usage tracking
- **Claude billing API** - Cost and usage monitoring

## Claude Usage Monitoring Use Cases

### For Claude API Developers
- Monitor **Claude API rate limits** during development
- Track **Claude token costs** for budget management
- Optimize **Claude prompt efficiency** and **Claude response lengths**
- Debug **Claude API quota exceeded** errors

### For Claude Pro Users
- Track **Claude Pro monthly limits** and **Claude conversation caps**
- Monitor **Claude Pro reset time** and **Claude subscription usage**
- Optimize **Claude Pro usage patterns** for maximum efficiency

### For Claude Enterprise Teams
- Monitor **Claude Enterprise usage** across team members
- Track **Claude API billing** and **Claude usage analytics**
- Manage **Claude workspace limits** and **Claude team quotas**

## Technical Implementation

Built with modern Swift for **Claude usage monitoring**:
- Efficient **Claude API data parsing** and **ccusage integration**
- Background **Claude usage polling** without performance impact
- Responsive **Claude data updates** with menu bar notifications
- **Claude usage caching** for offline monitoring
- **Claude API error handling** for reliable monitoring

## Keywords & SEO

This **Claude usage monitor** helps track: **ccusage**, **Claude API usage**, **Claude reset time**, **Claude token limits**, **Claude billing cycle**, **Claude usage tracking**, **Claude API monitor**, **Claude consumption tracker**, **Claude quota monitor**, **Claude limit tracker**, **Claude usage dashboard**, **Claude API analytics**, **Claude billing monitor**, **Claude reset countdown**, **Claude usage alerts**, **Claude token counter**, **Claude API dashboard**, **Claude usage statistics**, **Claude limit notifications**, **Claude consumption monitor**.

## Support & Documentation

- **GitHub Issues**: Report Claude monitoring bugs
- **Homebrew Formula**: Automated Claude monitor installation
- **Launch Agent**: Automatic Claude usage tracking on startup
- **Swift Package**: Easy Claude monitor integration

Track your **Claude usage** efficiently with this lightweight **Claude API monitor** for macOS.

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