// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TidalMenuBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TidalMenuBar",
            path: "Sources/TidalMenuBar"
        )
    ]
)
