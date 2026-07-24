import AppKit
import SwiftUI

/// The content drawn directly in the menu bar strip itself — not a
/// click-to-open popover. Buttons are live controls at all times; clicking
/// the track text brings Tidal to the front.
struct MenuBarControlsView: View {
    @ObservedObject var monitor: PlaybackMonitor

    var body: some View {
        HStack(spacing: 6) {
            if !monitor.isCLIAvailable {
                Text("nowplaying-cli missing")
                    .font(.system(size: 11))
            } else if let info = monitor.nowPlaying, info.title != nil {
                Text(trackLabel(info))
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .fixedSize()
                    .contentShape(Rectangle())
                    .onTapGesture { openTidal() }
            } else {
                Text("Nothing playing")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { openTidal() }
            }

            iconButton("backward.end.fill", action: monitor.previous)
            iconButton((monitor.nowPlaying?.isPlaying ?? false) ? "pause.fill" : "play.fill", action: monitor.togglePlayPause)
            iconButton("forward.end.fill", action: monitor.next)
        }
        .padding(.horizontal, 8)
        .frame(height: 22)
        .fixedSize()
    }

    private func iconButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12))
                .frame(width: 16, height: 16, alignment: .center)
        }
        .buttonStyle(.plain)
    }

    private func trackLabel(_ info: NowPlayingInfo) -> String {
        if let artist = info.artist, !artist.isEmpty {
            return "\(info.title ?? "") — \(artist)"
        }
        return info.title ?? ""
    }

    private func openTidal() {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.tidal.desktop") else { return }
        NSWorkspace.shared.open(url)
    }
}
