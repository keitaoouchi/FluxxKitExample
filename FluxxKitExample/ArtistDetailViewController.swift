import UIKit
import FluxxKit
import RxSwift

final class ArtistDetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var albumsContainerView: UIView!
  @IBOutlet weak var singlesContainerView: UIView!
  @IBOutlet weak var relatedArtistsContainerView: UIView!
  @IBOutlet weak var spotifyButton: UIButton!
  @IBOutlet var loadingView: UIView!
  @IBOutlet var emptyView: UIView!
  @IBOutlet var failedView: UIView!

  var artist: Artist!

  // swiftlint:disable:next force_unwrapping
  var albumVC = R.storyboard.coverCollection.instantiateInitialViewController()!

  // swiftlint:disable:next force_unwrapping
  var singleVC = R.storyboard.coverCollection.instantiateInitialViewController()!

  // swiftlint:disable:next force_unwrapping
  var artistsVC = R.storyboard.relatedArtistCollection.instantiateInitialViewController()!

  let store = Store<ArtistDetailViewModel, ArtistDetailViewModel.Action>(
      reducer: ArtistDetailViewModel.StoreReducer()
  )

  let disposeBag = DisposeBag()

  deinit {
    Dispatcher.shared.unregister(identifier: store.identifier)
  }

}

// MARK: - Lifecycle

extension ArtistDetailViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()

    Dispatcher.shared.dispatch(
      action: ArtistDetailViewModel.Action.requestImages(artist: artist),
      identifier: store.identifier
    )

    Dispatcher.shared.dispatch(
      action: ArtistDetailViewModel.Action.requestAlbumsAndSingles(artist: artist),
      identifier: store.identifier
    )

    Dispatcher.shared.dispatch(
      action: ArtistDetailViewModel.Action.requestRelatedArtists(artist: artist),
      identifier: store.identifier
    )
  }

  func setup() {
    addChildViewController(self.albumVC)
    albumVC.didMove(toParentViewController: self)
    addChildViewController(self.singleVC)
    singleVC.didMove(toParentViewController: self)
    addChildViewController(self.artistsVC)
    artistsVC.didMove(toParentViewController: self)

    self.setupView()
    self.bind(state: store.state)

    Dispatcher.shared.register(store: store)
  }

}

private extension ArtistDetailViewController {
  func setupView() {
    artistNameLabel.text = artist.name
    spotifyButton.addTarget(self, action: #selector(openSpotify), for: .touchUpInside)
  }

  func bind(state: ArtistDetailViewModel) {

    state
      .imagesRequestState.asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        switch state {
        case .done(let images):
          if let urlStr = images.first?.url, let url = URL(string: urlStr) {
            self?.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
          }
        default:
          break
        }
      }).addDisposableTo(self.disposeBag)

    state
      .albumsRequestState
      .asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        switch state {
        case .requesting:
          self?.albumsContainerView.fill(with: self?.loadingView)
        case .empty:
          self?.albumsContainerView.fill(with: self?.emptyView)
        case .failed(_):
          self?.albumsContainerView.fill(with: self?.failedView)
        case .done(let albums):
          self?.albumVC.albums = albums
          self?.albumsContainerView.fill(with: self?.albumVC.view)
          self?.albumVC.collectionView?.reloadData()
        }
      }).addDisposableTo(self.disposeBag)

    state
      .singlesRequestState
      .asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        switch state {
        case .requesting:
          self?.singlesContainerView.fill(with: self?.loadingView.clone())
        case .empty:
          self?.singlesContainerView.fill(with: self?.emptyView.clone())
        case .failed(_):
          self?.singlesContainerView.fill(with: self?.failedView.clone())
        case .done(let singles):
          self?.singleVC.albums = singles
          self?.singlesContainerView.fill(with: self?.singleVC.view)
          self?.singleVC.collectionView?.reloadData()
        }
      }).addDisposableTo(self.disposeBag)

    state
      .relatedArtistsRequestState
      .asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] state in
        switch state {
        case .requesting:
          self?.relatedArtistsContainerView.fill(with: self?.loadingView.clone())
        case .empty:
          self?.relatedArtistsContainerView.fill(with: self?.emptyView.clone())
        case .failed(_):
          self?.relatedArtistsContainerView.fill(with: self?.failedView.clone())
        case .done(let artists):
          self?.artistsVC.artists = artists
          self?.relatedArtistsContainerView.fill(with: self?.artistsVC.view)
          self?.artistsVC.collectionView?.reloadData()
        }
      }).addDisposableTo(self.disposeBag)
  }
}

extension ArtistDetailViewController {
  @objc func openSpotify() {
    if let urlStr = artist.spotifyUrl, let url = URL(string: urlStr),
       UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
}
