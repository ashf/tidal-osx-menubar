import Combine
import Foundation

@MainActor
final class PlaybackMonitor: ObservableObject {
    @Published private(set) var nowPlaying: NowPlayingInfo?
    @Published private(set) var isCLIAvailable = NowPlayingCLI.binaryPath != nil

    private var pollTimer: Timer?

    init() {
        refresh()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    deinit {
        pollTimer?.invalidate()
    }

    func togglePlayPause() {
        NowPlayingCLI.send(.togglePlayPause)
        refreshShortly()
    }

    func next() {
        NowPlayingCLI.send(.next)
        refreshShortly()
    }

    func previous() {
        NowPlayingCLI.send(.previous)
        refreshShortly()
    }

    private func refreshShortly() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            self.refresh()
        }
    }

    private func refresh() {
        Task.detached(priority: .utility) {
            let info = NowPlayingCLI.fetchNowPlayingInfo()
            await MainActor.run { self.nowPlaying = info }
        }
    }
}
