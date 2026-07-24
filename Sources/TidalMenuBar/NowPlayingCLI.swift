import Foundation

/// Wraps the `nowplaying-cli` binary (https://github.com/kirtan-shah/nowplaying-cli,
/// `brew install nowplaying-cli`).
///
/// Apple's private MediaRemote APIs for reading system Now Playing info are
/// unreliable to call directly in-process on current macOS — the standard
/// `MRMediaRemoteGetNowPlayingInfo` C entry point returns an empty result no
/// matter how it's invoked in-process on this OS build, while the external
/// `nowplaying-cli` tool (which uses a different internal path) still works.
/// Shelling out to it sidesteps that private-API drift entirely.
enum NowPlayingCLI {
    enum Command: String {
        case play, pause, togglePlayPause, next, previous
    }

    /// macOS's Now Playing session is system-wide, not per-app — whichever
    /// app last claimed it owns it, and `nowplaying-cli`'s commands act on
    /// that owner. To keep this widget Tidal-specific rather than a
    /// universal remote, info/controls are only surfaced when Tidal itself
    /// is the current owner.
    static let tidalBundleIdentifier = "com.tidal.desktop"

    private static let candidatePaths = [
        "/opt/homebrew/bin/nowplaying-cli",
        "/usr/local/bin/nowplaying-cli"
    ]

    static let binaryPath: String? = candidatePaths.first { FileManager.default.isExecutableFile(atPath: $0) }

    static func fetchNowPlayingInfo() -> NowPlayingInfo? {
        guard let binaryPath,
              let output = run(binaryPath, arguments: ["get-raw"]),
              let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        guard json["kMRMediaRemoteNowPlayingInfoClientBundleIdentifier"] as? String == tidalBundleIdentifier else {
            return nil
        }
        return NowPlayingInfo(rawJSON: json)
    }

    static func send(_ command: Command) {
        guard let binaryPath else { return }
        _ = run(binaryPath, arguments: [command.rawValue])
    }

    @discardableResult
    private static func run(_ path: String, arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8)
    }
}
