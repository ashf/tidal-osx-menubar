import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hostingView: StatusBarHostingView<MenuBarControlsView>!
    private let monitor = PlaybackMonitor()
    private var cancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let view = StatusBarHostingView(rootView: MenuBarControlsView(monitor: monitor))
        view.translatesAutoresizingMaskIntoConstraints = false

        if let button = item.button {
            button.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                view.topAnchor.constraint(equalTo: button.topAnchor),
                view.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
        }

        statusItem = item
        hostingView = view

        cancellable = monitor.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.resizeToFitContent() }
        }
        resizeToFitContent()
    }

    private func resizeToFitContent() {
        let width = max(hostingView.fittingSize.width, 1)
        statusItem.length = width
    }
}
