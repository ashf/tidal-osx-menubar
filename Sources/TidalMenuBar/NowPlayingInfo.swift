struct NowPlayingInfo {
    let title: String?
    let artist: String?
    let album: String?
    let isPlaying: Bool
    let elapsedTime: Double?
    let duration: Double?

    init(rawJSON json: [String: Any]) {
        title = json["kMRMediaRemoteNowPlayingInfoTitle"] as? String
        artist = json["kMRMediaRemoteNowPlayingInfoArtist"] as? String
        album = json["kMRMediaRemoteNowPlayingInfoAlbum"] as? String
        elapsedTime = json["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double
        duration = json["kMRMediaRemoteNowPlayingInfoDuration"] as? Double
        isPlaying = (json["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? 0) > 0
    }
}
