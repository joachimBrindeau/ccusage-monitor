import Cocoa

struct DisplayOption {
    let key: String
    let title: String
    let action: Selector
    var enabled: Bool
}

struct UsageData {
    let usedPct: Int
    let leftPct: Int
    let remainingMinutes: Int
    let totalTokens: Int
    let tokensLeft: Int
    let costCents: Int
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var options: [DisplayOption] = [
        DisplayOption(key: "usedPct", title: "Show % Used", action: #selector(toggleOption), enabled: true),
        DisplayOption(key: "leftPct", title: "Show % Left", action: #selector(toggleOption), enabled: false),
        DisplayOption(key: "timeLeft", title: "Show Time Left", action: #selector(toggleOption), enabled: true),
        DisplayOption(key: "tokensSpent", title: "Show Tokens Spent", action: #selector(toggleOption), enabled: false),
        DisplayOption(key: "tokensLeft", title: "Show Tokens Left", action: #selector(toggleOption), enabled: false),
        DisplayOption(key: "moneySpent", title: "Show Money Spent", action: #selector(toggleOption), enabled: false)
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Loading..."
        buildMenu()
        updateUsage()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.updateUsage() }
    }

    private func buildMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(updateUsage), keyEquivalent: "r"))
        menu.addItem(.separator())

        for (index, option) in options.enumerated() {
            let item = NSMenuItem(title: option.title, action: #selector(toggleOption(_:)), keyEquivalent: "")
            item.state = option.enabled ? .on : .off
            item.tag = index
            menu.addItem(item)
        }

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
            self.statusItem.button?.title = display.isEmpty ? "No metrics" : display.joined(separator: " | ")
        }
    }

    private func parseUsageData(from block: [String: Any]) -> UsageData {
        let totalTokens = block["totalTokens"] as? Int ?? 1
        let projection = block["projection"] as? [String: Any]
        let projectedTotal = projection?["totalTokens"] as? Int ?? totalTokens
        let remainingMinutes = projection?["remainingMinutes"] as? Int ?? 0
        let costCents = block["costCents"] as? Int ?? 0

        // Calculate percentage exactly like ccusage does
        let tokenLimitStatus = block["tokenLimitStatus"] as? [String: Any]
        let limit = tokenLimitStatus?["limit"] as? Int ?? totalTokens

        // Used percentage: (currentTokens / limit) * 100
        let usedPct = limit > 0 ? Int(((Double(totalTokens) / Double(limit)) * 100).rounded()) : 0

        // Remaining percentage: ((limit - currentTokens) / limit) * 100
        let leftPct = limit > 0 ? Int((((Double(limit) - Double(totalTokens)) / Double(limit)) * 100).rounded()) : 100

        return UsageData(
            usedPct: usedPct,
            leftPct: leftPct,
            remainingMinutes: remainingMinutes,
            totalTokens: totalTokens,
            tokensLeft: max(0, limit - totalTokens),
            costCents: costCents
        )
    }

    private func buildDisplayString(from usage: UsageData) -> [String] {
        var display: [String] = []

        for option in options where option.enabled {
            switch option.key {
            case "usedPct": display.append("\(usage.usedPct)%")
            case "leftPct": display.append("\(usage.leftPct)% left")
            case "timeLeft": display.append("\(usage.remainingMinutes/60)h \(usage.remainingMinutes%60)m")
            case "tokensSpent": display.append("\(formatTokens(usage.totalTokens))t")
            case "tokensLeft": display.append("\(formatTokens(usage.tokensLeft))t left")
            case "moneySpent": display.append("$\(String(format: "%.2f", Double(usage.costCents)/100))")
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
        options[sender.tag].enabled.toggle()
        buildMenu()
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