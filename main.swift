import Cocoa

struct UsageData {
    let usedPct: Int
    let leftPct: Int
    let remainingMinutes: Int
    let elapsedMinutes: Int
    let totalTokens: Int
    let tokensLeft: Int
    let costUsed: Double
    let costLeft: Double
    let resetTime: String
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var currentUsage: UsageData?
    private var options = ["percentage": true, "timeLeft": true, "tokens": false, "money": false]
    private var showUsed = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Loading..."
        buildMenu()
        updateUsage()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.updateUsage() }
    }

    private func buildMenu() {
        let menu = NSMenu()

        if let usage = currentUsage {
            let resetItem = NSMenuItem(title: "Next reset: \(usage.resetTime)", action: nil, keyEquivalent: "")
            resetItem.isEnabled = false
            menu.addItem(resetItem)
            menu.addItem(.separator())
        }

        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(updateUsage), keyEquivalent: "r"))
        menu.addItem(.separator())

        for (index, (key, enabled)) in options.enumerated() {
            let titles = ["percentage": "Show Percentage", "timeLeft": "Show Time", "tokens": "Show Tokens", "money": "Show Money"]
            let item = NSMenuItem(title: titles[key]!, action: #selector(toggleOption(_:)), keyEquivalent: "")
            item.state = enabled ? .on : .off
            item.tag = index
            if key == "money" && !showUsed { item.isEnabled = false; item.action = nil; item.state = .off }
            menu.addItem(item)
        }

        menu.addItem(.separator())
        let usedLeftItem = NSMenuItem(title: showUsed ? "Show left instead of used" : "Show used instead of left", action: #selector(toggleUsedLeft), keyEquivalent: "")
        menu.addItem(usedLeftItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func updateUsage() {
        let process = Process()

        // Try to use CCUSAGE_PATH environment variable first, then fallback to npx
        let ccusagePath = ProcessInfo.processInfo.environment["CCUSAGE_PATH"] ?? "npx"
        let arguments = ccusagePath == "npx" ? ["npx", "ccusage"] : [ccusagePath]

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments + ["blocks", "--active", "--json", "--token-limit", "max"]

        let pipe = Pipe()
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilExit()

        guard let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8),
              let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let blocks = json["blocks"] as? [[String: Any]],
              let block = blocks.first else {
            DispatchQueue.main.async { self.statusItem.button?.title = "No data" }
            return
        }

        let usage = parseUsageData(from: block)
        let display = buildDisplayString(from: usage)

        DispatchQueue.main.async {
            self.currentUsage = usage
            self.statusItem.button?.title = display.isEmpty ? "No metrics" : display.joined(separator: " | ")
            self.buildMenu()
        }
    }

    private func parseUsageData(from block: [String: Any]) -> UsageData {
        let totalTokens = block["totalTokens"] as? Int ?? 1
        let projection = block["projection"] as? [String: Any]
        let projectedTotal = projection?["totalTokens"] as? Int ?? totalTokens
        let remainingMinutes = projection?["remainingMinutes"] as? Int ?? 0
        let costUsed = block["costUSD"] as? Double ?? 0.0
        let projectedCost = projection?["totalCost"] as? Double ?? 0.0

        // Use ccusage's exact percentage calculation
        let tokenLimitStatus = block["tokenLimitStatus"] as? [String: Any]
        let limit = tokenLimitStatus?["limit"] as? Int ?? totalTokens
        let ccusagePercentUsed = tokenLimitStatus?["percentUsed"] as? Double ?? 0.0

        let totalBlockMinutes = 5 * 60 // 5 hours = 300 minutes
        let elapsedMinutes = totalBlockMinutes - remainingMinutes

        // Use ccusage's percentUsed (which includes projection)
        let usedPct = Int(ccusagePercentUsed.rounded())
        let leftPct = max(0, 100 - usedPct)

        let tokensLeft = max(0, limit - totalTokens)
        let costLeft = projectedCost - costUsed

        return UsageData(
            usedPct: usedPct,
            leftPct: leftPct,
            remainingMinutes: remainingMinutes,
            elapsedMinutes: elapsedMinutes,
            totalTokens: totalTokens,
            tokensLeft: tokensLeft,
            costUsed: costUsed,
            costLeft: costLeft,
            resetTime: formatResetTime(remainingMinutes: remainingMinutes)
        )
    }

    private func formatResetTime(remainingMinutes: Int) -> String {
        let now = Date()
        let resetDate = Calendar.current.date(byAdding: .minute, value: remainingMinutes, to: now)!

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: resetDate)
    }

    private func buildDisplayString(from usage: UsageData) -> [String] {
        var display: [String] = []

        for (key, enabled) in options where enabled {
            switch key {
            case "percentage": display.append("\(showUsed ? usage.usedPct : usage.leftPct)%")
            case "timeLeft": display.append("\((showUsed ? usage.elapsedMinutes : usage.remainingMinutes)/60)h \((showUsed ? usage.elapsedMinutes : usage.remainingMinutes)%60)m")
            case "tokens": display.append("\(formatTokens(showUsed ? usage.totalTokens : usage.tokensLeft))t")
            case "money": if showUsed { display.append("$\(String(format: "%.2f", usage.costUsed))") }
            default: break
            }
        }

        return display
    }

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000)
        } else {
            return "\(tokens)"
        }
    }

    @objc private func toggleOption(_ sender: NSMenuItem) {
        let key = Array(options.keys)[sender.tag]
        if key == "money" && !showUsed { return }
        options[key]!.toggle()
        refreshUI()
    }

    @objc private func toggleUsedLeft() {
        showUsed.toggle()

        if !showUsed { options["money"] = false }

        refreshUI()
    }

    private func refreshUI() {
        buildMenu()
        DispatchQueue.main.async {
            self.statusItem.button?.title = "..."
        }
        updateUsage()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()