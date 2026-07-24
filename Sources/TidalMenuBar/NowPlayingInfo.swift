struct NowPlayingInfo {
    let title: String?
    let artist: String?
    let album: String?
    let isPlaying: Bool
    let elapsedTime: Double?
    let duration: Double?

    init(json: [String: Any]) {
        title = json["title"] as? String
        artist = json["artist"] as? String
        album = json["album"] as? String
        elapsedTime = json["elapsedTime"] as? Double
        duration = json["duration"] as? Double
        isPlaying = (json["playbackRate"] as? Double ?? 0) > 0
    }
}
