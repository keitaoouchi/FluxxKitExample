import UIKit
import RxSwift

final class SupplementalStateViewController: UIViewController {
  @IBOutlet var loadingView: UIView!
  @IBOutlet var failedView: UIView!
  @IBOutlet var initView: SearchInitView!
  @IBOutlet var emptyView: UIView!
  let disposeBag = DisposeBag()
}

// MARK: - Lifecycle

extension SupplementalStateViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.initView.spotifyButton.addTarget(self, action: #selector(openSpotify), for: .touchUpInside)
  }
}

extension SupplementalStateViewController {

  func bind(state: SearchViewModel) {
    state
        .searchState
        .asObservable()
        .observeOn(MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] state in
              switch state {
              case .initial:
                self?.showInitial()
              case .empty:
                self?.showEmpty()
              case .failed(error: _):
                self?.showFailed()
              case .searching:
                self?.showLoading()
              default:
                break
              }
            }
        ).addDisposableTo(self.disposeBag)
  }

  @objc func openSpotify() {
    if let url = URL(string: "https://open.spotify.com"), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
}

private extension SupplementalStateViewController {

  func showInitial() {
    view.fill(with: initView)
  }

  func showEmpty() {
    view.fill(with: emptyView)
  }

  func showFailed() {
    view.fill(with: failedView)
  }

  func showLoading() {
    view.fill(with: loadingView)
  }
}
