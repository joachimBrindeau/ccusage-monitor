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
    let costUsed: Double
    let costLeft: Double
    let resetTime: String
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var currentUsage: UsageData?
    private var options: [DisplayOption] = [
        DisplayOption(key: "percentage", title: "Show Percentage", action: #selector(toggleOption), enabled: true),
        DisplayOption(key: "timeLeft", title: "Show Time", action: #selector(toggleOption), enabled: true),
        DisplayOption(key: "tokens", title: "Show Tokens", action: #selector(toggleOption), enabled: false),
        DisplayOption(key: "money", title: "Show Money", action: #selector(toggleOption), enabled: false)
    ]
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

        for (index, option) in options.enumerated() {
            let item = NSMenuItem(title: option.title, action: #selector(toggleOption(_:)), keyEquivalent: "")
            item.state = option.enabled ? .on : .off
            item.tag = index

            if option.key == "money" && !showUsed {
                item.isEnabled = false
                item.action = nil
                item.state = .off
            }

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
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["npx", "ccusage", "blocks", "--active", "--json"]

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

        let usedPct = totalTokens * 100 / projectedTotal
        let leftPct = 100 - usedPct
        let tokensLeft = projectedTotal - totalTokens
        let costLeft = projectedCost - costUsed

        return UsageData(
            usedPct: usedPct,
            leftPct: leftPct,
            remainingMinutes: remainingMinutes,
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

        for option in options where option.enabled {
            switch option.key {
            case "percentage":
                if showUsed {
                    display.append("\(usage.usedPct)%")
                } else {
                    display.append("\(usage.leftPct)%")
                }
            case "timeLeft": display.append("\(usage.remainingMinutes/60)h \(usage.remainingMinutes%60)m")
            case "tokens":
                if showUsed {
                    display.append("\(formatTokens(usage.totalTokens))t")
                } else {
                    display.append("\(formatTokens(usage.tokensLeft))t")
                }
            case "money":
                if showUsed {
                    display.append("$\(String(format: "%.2f", usage.costUsed))")
                } else {
                    display.append("$\(String(format: "%.2f", usage.costLeft))")
                }
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
        let option = options[sender.tag]

        if option.key == "money" && !showUsed {
            return
        }

        options[sender.tag].enabled.toggle()
        refreshUI()
    }

    @objc private func toggleUsedLeft() {
        showUsed.toggle()

        if !showUsed {
            if let moneyIndex = options.firstIndex(where: { $0.key == "money" }) {
                options[moneyIndex].enabled = false
            }
        }

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