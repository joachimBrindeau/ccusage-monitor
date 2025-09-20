// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ccusage-monitor",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "ccusage-monitor",
            targets: ["CCUsageMonitor"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CCUsageMonitor",
            path: "Sources"
        )
    ]
)