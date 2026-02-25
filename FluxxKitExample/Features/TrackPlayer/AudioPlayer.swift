import AVFoundation

@MainActor
final class AudioPlayer {
    private var player: AVPlayer?
    private var endObservation: Task<Void, Never>?

    func play(track: Track, onEnded: @escaping @Sendable () async -> Void) {
        guard let urlString = track.previewUrl,
              let url = URL(string: urlString) else { return }

        stop()

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        player.play()

        endObservation = Task {
            let notifications = NotificationCenter.default.notifications(
                named: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
            for await _ in notifications {
                await onEnded()
                break
            }
        }
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func stop() {
        endObservation?.cancel()
        endObservation = nil
        player?.pause()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
