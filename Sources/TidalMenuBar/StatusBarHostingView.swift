import AppKit
import SwiftUI

/// NSHostingView subclass that adds a right-click context menu (Quit),
/// since the status item itself has no `.menu` — that would hijack every
/// click (including the play/pause/next controls) into a menu instead.
final class StatusBarHostingView<Content: View>: NSHostingView<Content> {
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit TidalMenuBar", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
