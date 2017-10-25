import UIKit
import IoniconsKit
import Kingfisher
import RxSwift
import FluxxKit

class TrackPlayerViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playerButton: UIButton!

  var coverImageUrl: URL?
  let disposeBag = DisposeBag()
  let store = Store<TrackPlayerViewModel, TrackPlayerViewModel.Action>(reducer: TrackPlayerViewModel.StoreReducer())
  static var shared = TrackPlayerViewController(nib: R.nib.trackPlayerViewController)
}

// MARK: - Lifecycle

extension TrackPlayerViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    playerButton.setTitle(String.ionicon(with: .play), for: .normal)
    playerButton.isHidden = true
    playerButton.addTarget(self, action: #selector(toggleCurrentTrack), for: .touchUpInside)
    self.bind(state: store.state)
    Dispatcher.shared.register(store: store)
  }

}

extension TrackPlayerViewController {

  func bind(state: TrackPlayerViewModel) {
    Observable
      .combineLatest(state.playerState.asObservable(), state.trackStream.asObservable())
        .observeOn(MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] playerState, track in
              guard let track = track else { return }

              switch playerState {

              case .ready:
                if let urlStr = track.album?.images.first?.url, let url = URL(string: urlStr) {
                  self?.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                self?.titleLabel.text = track.name
                self?.playerButton.setTitle(String.ionicon(with: .play), for: .normal)
                self?.playerButton.isHidden = false

              case .playing:
                if let urlStr = track.album?.images.first?.url, let url = URL(string: urlStr) {
                  self?.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                self?.titleLabel.text = track.name
                self?.playerButton.setTitle(String.ionicon(with: .pause), for: .normal)
                self?.playerButton.isHidden = false

              case .paused:
                if let urlStr = track.album?.images.first?.url, let url = URL(string: urlStr) {
                  self?.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                self?.titleLabel.text = track.name
                self?.playerButton.setTitle(String.ionicon(with: .play), for: .normal)
                self?.playerButton.isHidden = false

              }
            }
        ).disposed(by: self.disposeBag)
  }

}

// MARK: - UIActions

private extension TrackPlayerViewController {
  @objc func toggleCurrentTrack(sender: Any) {
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.toggleCurrentTrack)
  }
}
