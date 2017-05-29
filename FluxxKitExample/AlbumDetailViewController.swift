import UIKit
import RxSwift
import FluxxKit

final class AlbumDetailViewController: UIViewController {
  @IBOutlet weak var coverImageView: UIImageView!
  @IBOutlet weak var albumTitle: UILabel!
  @IBOutlet weak var artistNameButton: UIButton!
  @IBOutlet weak var releaseLabel: UILabel!
  @IBOutlet weak var spotifyButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

  // swiftlint:disable:next force_cast
  var album: Album!
  // swiftlint:disable:next force_unwrapping
  let supplementalVC = R.storyboard.requestSupplementalState.instantiateInitialViewController()!
  // swiftlint:disable:next force_unwrapping
  let trackTableVC = R.storyboard.trackTable.instantiateInitialViewController()!

  let trackPlayerVC = TrackPlayerViewController.shared
  var playerHeight: CGFloat = 56.0
  var playerBottomConstraint: NSLayoutConstraint?
  let disposeBag = DisposeBag()
  let store = Store<AlbumDetailViewModel, AlbumDetailViewModel.Action>(
      reducer: AlbumDetailViewModel.StoreReducer()
  )

  deinit {
    Dispatcher.shared.unregister(store: store)
  }
}

// MARK: - Lifecycle

extension AlbumDetailViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()

    Dispatcher.shared.dispatch(
      action: AlbumDetailViewModel.Action.request(album: album),
      identifier: store.identifier
    )
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.addTrackPlayerView()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.show)
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.removeTrackPlayerView()
  }

  func setup() {
    self.setupView()
    self.bindStores()
    Dispatcher.shared.register(store: store)
  }

  func addTrackPlayerView() {
    if let playerView = self.trackPlayerVC.view {
      self.addChildViewController(self.trackPlayerVC)
      playerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(playerView)
      self.playerBottomConstraint = playerView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: self.playerHeight)
      self.playerBottomConstraint?.isActive = true
      playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -4).isActive = true
      playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 4).isActive = true
      playerView.heightAnchor.constraint(equalToConstant: playerHeight).isActive = true
      playerView.bringSubview(toFront: view)
      trackPlayerVC.didMove(toParentViewController: self)
    }
  }

  func removeTrackPlayerView() {
    if let playerView = self.trackPlayerVC.view {
      playerView.removeFromSuperview()
      trackPlayerVC.removeFromParentViewController()
    }
  }

}

// MARK: - Setup & Bind view

private extension AlbumDetailViewController {

  func setupView() {
    if let urlStr = album.images.first?.url, let url = URL(string: urlStr) {
      coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }

    albumTitle.text = album.title
    artistNameButton.setTitle(album.artists.first?.name, for: .normal)
    artistNameButton.addTarget(self, action: #selector(showArtistDetail), for: .touchUpInside)
    trackTableVC.tableView.isScrollEnabled = false
    trackTableVC.album = album
    trackTableVC.onLoad = { [weak self] in
      if let height = self?.trackTableVC.tableView.contentSize.height {
        self?.containerViewHeight.constant = height
      }
    }

    if let urlStr = album.images.first?.url {
      self.trackPlayerVC.coverImageUrl = URL(string: urlStr)
    }

    spotifyButton.addTarget(self, action: #selector(openSpotify), for: .touchUpInside)

  }

  func bindStores() {
    self.supplementalVC.bind(state: store.state)
    self.trackTableVC.bind(state: store.state)
    self.bind(state: store.state)
    self.trackTableVC.bind(state: trackPlayerVC.store.state)
    self.bind(state: trackPlayerVC.store.state)
  }

  func bind(state: AlbumDetailViewModel) {
    state.requestState.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] state in
      switch state {
      case .done:
        self?.containerView.fill(with: self?.trackTableVC.view)
      default:
        self?.containerView.fill(with: self?.supplementalVC.view)
      }
    }).addDisposableTo(self.disposeBag)
  }

  func bind(state: TrackPlayerViewModel) {
    Observable.combineLatest(
        state.hiddenState.asObservable(), state.playerState.asObservable()
    ).asObservable().observeOn(
        MainScheduler.instance
    ).subscribe(onNext: { [weak self] displayState, playerState in

      switch playerState {
      case .ready:
        switch displayState {
        case .showing:
          break
        case .hidden:
          self?.hidePlayer()
        }
      default:
        switch displayState {
        case .showing:
          self?.showPlayer()
        case .hidden:
          self?.hidePlayer()
        }
      }
    }).addDisposableTo(self.disposeBag)
  }
}

// MARK: - UIAnimations

private extension AlbumDetailViewController {
  func showPlayer() {
    self.playerBottomConstraint?.constant = 0
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.view.layoutIfNeeded()
    })
  }

  func hidePlayer() {
    self.playerBottomConstraint?.constant = self.playerHeight
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.view.layoutIfNeeded()
    })
  }
}

// MARK: - UIActions

private extension AlbumDetailViewController {

  @objc func showArtistDetail() {
    if let artist = album.artists.first,
       let vc = R.storyboard.artistDetail.instantiateInitialViewController() {
      vc.artist = artist
      navigationController?.pushViewController(vc, animated: true)
    }
  }

  @objc func openSpotify() {
    if let urlStr = album.spotifyUrl, let url = URL(string: urlStr),
       UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
}

// MARK: - UIScrollViewDelegate

extension AlbumDetailViewController: UIScrollViewDelegate {

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    let trans = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
    if trans.y < 0 {
      Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.hide)
    } else {
      Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.show)
    }
  }
}
