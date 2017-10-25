import UIKit
import RxSwift

final class RequestSupplementalStateViewController: UIViewController {
  @IBOutlet var loadingView: UIView!
  @IBOutlet var failedView: UIView!
  @IBOutlet var emptyView: UIView!
  let disposeBag = DisposeBag()
}

// MARK: - Lifecycle
extension RequestSupplementalStateViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension RequestSupplementalStateViewController {

  func bind(state: AlbumDetailViewModel) {
    state.requestState.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] state in
      switch state {
      case .empty:
        self?.showEmpty()
      case .failed:
        self?.showFailed()
      case .requesting:
        self?.showLoading()
      default:
        break
      }
    }).disposed(by: self.disposeBag)
  }

}

private extension RequestSupplementalStateViewController {

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
