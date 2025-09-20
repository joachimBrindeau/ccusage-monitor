import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var s: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        s = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        s.button?.title = "Loading..."
        let m = NSMenu()
        m.addItem(NSMenuItem(title: "Refresh", action: #selector(u), keyEquivalent: "r"))
        m.addItem(.separator())
        m.addItem(NSMenuItem(title: "Quit", action: #selector(q), keyEquivalent: "q"))
        s.menu = m
        u()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.u() }
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

        let t = b["totalTokens"] as? Int ?? 1
        let pr = (b["projection"] as? [String: Any])?["totalTokens"] as? Int ?? t
        let m = (b["projection"] as? [String: Any])?["remainingMinutes"] as? Int ?? 0

        DispatchQueue.main.async {
            self.s.button?.title = "\(t * 100 / pr)% | \(m/60)h \(m%60)m"
        }
    }

    @objc func q() { NSApplication.shared.terminate(nil) }
}

NSApplication.shared.delegate = AppDelegate()
NSApplication.shared.run()