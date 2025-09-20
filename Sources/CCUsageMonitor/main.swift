import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Loading..."
        statusItem.menu = NSMenu().then {
            $0.addItem(NSMenuItem(title: "Refresh", action: #selector(update), keyEquivalent: "r"))
            $0.addItem(.separator())
            $0.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        }
        update()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.update() }
    }

    @objc func update() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        p.arguments = ["npx", "ccusage", "blocks", "--active", "--json"]
        let pipe = Pipe()
        p.standardOutput = pipe
        try? p.run()
        p.waitUntilExit()

        guard let data = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!) as? [String: Any],
              let block = (json["blocks"] as? [[String: Any]])?.first else {
            DispatchQueue.main.async { self.statusItem.button?.title = "No data" }
            return
        }

        let total = block["totalTokens"] as? Int ?? 1
        let proj = (block["projection"] as? [String: Any])?["totalTokens"] as? Int ?? total
        let mins = (block["projection"] as? [String: Any])?["remainingMinutes"] as? Int ?? 0

        DispatchQueue.main.async {
            self.statusItem.button?.title = "\(total * 100 / proj)% | \(mins/60)h \(mins%60)m"
        }
    }

    @objc func quit() { NSApplication.shared.terminate(nil) }
}

extension NSMenu {
    func then(_ block: (NSMenu) -> Void) -> NSMenu { block(self); return self }
}

let app = NSApplication.shared
app.delegate = AppDelegate()
app.run()