import AVFoundation
import RxSwift
import RxAudioVisual

final class TrackPlayer {

  var trackStream = Variable<Track?>(nil)
  var state = Variable<State>(.ready)
  var volume: Float = 1.0
  private var player: AVPlayer?
  private var readyToPlayObservable: Disposable?
  private var didPlayToEndObservable: Disposable?

  enum State {
    case ready
    case playing
    case paused
  }

  deinit {
    self.readyToPlayObservable?.dispose()
    self.didPlayToEndObservable?.dispose()
  }

  func stop() {
    self.readyToPlayObservable?.dispose()
    self.didPlayToEndObservable?.dispose()

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

    if let asset = player?.currentItem?.asset as? AVURLAsset, url == asset.url {
      DispatchQueue.main.async {

        try? AVAudioSession.sharedInstance().setActive(true)

        self.player?.play()
        self.state.value = .playing
      }
    } else {
      let item = AVPlayerItem(url: url)
      let player = AVPlayer(playerItem: item)

      self.bind(player: player)
      self.bind(item: item)
      self.trackStream.value = track
    }
  }

  private func bind(player: AVPlayer) {
    self.readyToPlayObservable?.dispose()
    self.readyToPlayObservable = player.rx.status.filter { $0 == .readyToPlay }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let `self` = self else { return }

        self.state.value = .playing

        try? AVAudioSession.sharedInstance().setActive(true)

        player.volume = self.volume
        player.play()
        self.player = player
      })
  }

  private func bind(item: AVPlayerItem) {
    self.didPlayToEndObservable?.dispose()
    self.didPlayToEndObservable = item
      .rx
      .didPlayToEnd
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.stop()
      })
  }

}
