# CCUsage Monitor - Ultra-Minimal Claude API Usage in macOS Menu Bar

I built a **181-line Swift app** that puts your Claude usage directly in your menu bar, because I wanted something completely debloated.

## Why Another Monitor?

Yes, there are other solutions out there - Activity Monitor, third-party apps, browser extensions, etc. But I wanted something that:

- **Runs natively** - No Electron bloat, no web dependencies
- **Uses zero resources** - 46 lines of Swift, updates every 30 seconds
- **Shows exactly what I need** - Current block progress, not lifetime stats
- **Stays out of the way** - Menu bar only, no windows or dashboards

## What It Shows

Built on the trusted [ccusage CLI](https://github.com/evanmschultz/ccusage), it displays your **current 5-hour billing block** progress:

- **Percentage used/left** (92% or 8% left)
- **Time elapsed/remaining** (3h 45m used or 1h 15m left)
- **Tokens used/left** (234.7M used or 97.5M left)
- **Money spent** ($160.83 - only when showing "used")

Right-click toggles what to show, plus a switch between "used" vs "left" metrics.

## Installation

```bash
# Homebrew (includes auto-start)
brew tap joachimbrindeau/ccusage-monitor
brew install ccusage-monitor

# Or one-command install
git clone https://github.com/joachimBrindeau/ccusage-monitor.git
cd ccusage-monitor && ./install
```

## The Minimalist Approach

The entire app logic fits in 181 lines. It spawns `npx ccusage blocks --active --json` every 30 seconds, parses the response, and updates the menu bar. That's it.

No frameworks, no databases, no background services. Just native macOS APIs doing exactly one job well.

**Repo**: https://github.com/joachimBrindeau/ccusage-monitor

For those who prefer their tools lean and focused. 🚀