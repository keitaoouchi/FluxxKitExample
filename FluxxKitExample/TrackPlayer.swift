import AVFoundation
import RxSwift

final class TrackPlayer {

  var trackStream = Variable<Track?>(nil)
  var state = Variable<State>(.ready)
  private let disposeBag = DisposeBag()

  enum State {
    case ready
    case playing
    case paused
  }

  var volume: Float = 1.0
  private var player: AVPlayer?

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onFinishedAudioPlaying),
      name: Notification.Name.AVPlayerItemDidPlayToEndTime,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func stop() {
    player?.pause()
    self.player = nil
    try? AVAudioSession.sharedInstance().setActive(false)

    state.value = .ready
  }

  func pause() {
    player?.pause()

    DispatchQueue.main.async {
      try? AVAudioSession.sharedInstance().setActive(false)
    }

    state.value = .paused
  }

  func replay() {
    if let track = trackStream.value {
      self.play(track: track)
    }
  }

  func play(track: Track) {
    guard let url = URL(string: track.previewUrl) else { return }

    DispatchQueue.main.async {
      try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      try? AVAudioSession.sharedInstance().setActive(true)
    }

    if let asset = player?.currentItem?.asset as? AVURLAsset,
       url == asset.url {
      self.player?.play()
    } else {
      let item = AVPlayerItem(url: url)
      self.player = AVPlayer(playerItem: item)
      self.player?.volume = self.volume
      self.player?.play()

      trackStream.value = track
    }

    state.value = .playing
  }

  @objc func onFinishedAudioPlaying(notification: Notification) {
    self.stop()
  }
}
