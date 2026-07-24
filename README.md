# TidalMenuBar

A macOS menu bar widget for controlling the Tidal desktop app. Playback
controls (prev/play-pause/next) and the current track name are drawn
directly in the menu bar strip itself — no dropdown or popup required.

> Written with [Claude Code](https://claude.com/claude-code).

## How it works

Tidal's desktop app has no public API or AppleScript dictionary, so this
app controls it the same way a physical keyboard's media keys do, via
macOS's system-wide Now Playing / media remote layer. Both reading status
and sending commands are done by shelling out to
[`nowplaying-cli`](https://github.com/kirtan-shah/nowplaying-cli)
(`brew install nowplaying-cli`), rather than calling Apple's private
`MediaRemote.framework` in-process: on current macOS,
`MRMediaRemoteGetNowPlayingInfo` reliably returns empty data no matter how
it's invoked in-process, while `nowplaying-cli` (which uses a different
internal path) still works. Shelling out to it sidesteps that private-API
drift entirely.

This means control is limited to transport actions (play/pause/next/prev)
and whatever now-playing metadata Tidal publishes to the system — no
access to search, playlists, or library browsing.

## Requirements

- macOS 13+
- Swift 5.9+ (Xcode 15+ or the Swift toolchain)
- [`nowplaying-cli`](https://github.com/kirtan-shah/nowplaying-cli): `brew install nowplaying-cli`
- Tidal desktop app running and playing something for status/control to work

## Build & run

```sh
./Scripts/build-app.sh        # builds TidalMenuBar.app (debug)
open TidalMenuBar.app
```

`swift run` alone is not enough — several menu bar / status item behaviors
expect a real, LaunchServices-registered `.app` bundle rather than a bare
executable, so the build script packages one using `Resources/Info.plist`.

Pass `release` to build optimized: `./Scripts/build-app.sh release`.

## Notes

- Right-click the menu bar item for a Quit option.
- If you see "nowplaying-cli missing" in the menu bar, install it via
  Homebrew (see Requirements) and relaunch.
