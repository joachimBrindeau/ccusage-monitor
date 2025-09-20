import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var s: NSStatusItem!
    var showUsedPct = true
    var showLeftPct = false
    var showTimeLeft = true
    var showTokensSpent = false
    var showTokensLeft = false
    var showMoneySpent = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        s = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        s.button?.title = "Loading..."
        buildMenu()
        u()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.u() }
    }

    func buildMenu() {
        let m = NSMenu()
        m.addItem(NSMenuItem(title: "Refresh", action: #selector(u), keyEquivalent: "r"))
        m.addItem(.separator())

        let usedItem = NSMenuItem(title: "Show % Used", action: #selector(toggleUsedPct), keyEquivalent: "")
        usedItem.state = showUsedPct ? .on : .off
        m.addItem(usedItem)

        let leftItem = NSMenuItem(title: "Show % Left", action: #selector(toggleLeftPct), keyEquivalent: "")
        leftItem.state = showLeftPct ? .on : .off
        m.addItem(leftItem)

        let timeItem = NSMenuItem(title: "Show Time Left", action: #selector(toggleTimeLeft), keyEquivalent: "")
        timeItem.state = showTimeLeft ? .on : .off
        m.addItem(timeItem)

        let spentItem = NSMenuItem(title: "Show Tokens Spent", action: #selector(toggleTokensSpent), keyEquivalent: "")
        spentItem.state = showTokensSpent ? .on : .off
        m.addItem(spentItem)

        let tokensLeftItem = NSMenuItem(title: "Show Tokens Left", action: #selector(toggleTokensLeft), keyEquivalent: "")
        tokensLeftItem.state = showTokensLeft ? .on : .off
        m.addItem(tokensLeftItem)

        let moneyItem = NSMenuItem(title: "Show Money Spent", action: #selector(toggleMoneySpent), keyEquivalent: "")
        moneyItem.state = showMoneySpent ? .on : .off
        m.addItem(moneyItem)

        m.addItem(.separator())
        m.addItem(NSMenuItem(title: "Quit", action: #selector(q), keyEquivalent: "q"))
        s.menu = m
    }

    @objc func u() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        p.arguments = ["npx", "ccusage", "blocks", "--active", "--json"]
        let pipe = Pipe()
        p.standardOutput = pipe
        try? p.run()
        p.waitUntilExit()

        guard let d = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8),
              let j = try? JSONSerialization.jsonObject(with: d.data(using: .utf8)!) as? [String: Any],
              let b = (j["blocks"] as? [[String: Any]])?.first else {
            DispatchQueue.main.async { self.s.button?.title = "No data" }
            return
        }

        let totalTokens = b["totalTokens"] as? Int ?? 1
        let projection = (b["projection"] as? [String: Any])
        let projectedTotal = projection?["totalTokens"] as? Int ?? totalTokens
        let remainingMinutes = projection?["remainingMinutes"] as? Int ?? 0
        let costCents = b["costCents"] as? Int ?? 0

        let usedPct = totalTokens * 100 / projectedTotal
        let leftPct = 100 - usedPct
        let tokensLeft = projectedTotal - totalTokens
        let moneyCents = costCents

        var display: [String] = []
        if showUsedPct { display.append("\(usedPct)%") }
        if showLeftPct { display.append("\(leftPct)% left") }
        if showTimeLeft { display.append("\(remainingMinutes/60)h \(remainingMinutes%60)m") }
        if showTokensSpent { display.append("\(totalTokens)t") }
        if showTokensLeft { display.append("\(tokensLeft)t left") }
        if showMoneySpent { display.append("$\(String(format: "%.2f", Double(moneyCents)/100))") }

        DispatchQueue.main.async {
            self.s.button?.title = display.isEmpty ? "No metrics" : display.joined(separator: " | ")
        }
    }

    @objc func toggleUsedPct() { showUsedPct.toggle(); buildMenu(); u() }
    @objc func toggleLeftPct() { showLeftPct.toggle(); buildMenu(); u() }
    @objc func toggleTimeLeft() { showTimeLeft.toggle(); buildMenu(); u() }
    @objc func toggleTokensSpent() { showTokensSpent.toggle(); buildMenu(); u() }
    @objc func toggleTokensLeft() { showTokensLeft.toggle(); buildMenu(); u() }
    @objc func toggleMoneySpent() { showMoneySpent.toggle(); buildMenu(); u() }

    @objc func q() { NSApplication.shared.terminate(nil) }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()