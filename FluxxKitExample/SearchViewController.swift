import UIKit
import FluxxKit
import RxSwift

final class SearchViewController: UIViewController {
  @IBOutlet weak var containerView: UIView!

  // swiftlint:disable:next force_unwrapping
  let supplementalVC = R.storyboard.supplementalState.instantiateInitialViewController()!
  // swiftlint:disable:next force_unwrapping
  let albumCoverTableVC = R.storyboard.albumCard.instantiateInitialViewController()!
  let store = Store<SearchViewModel, SearchViewModel.Action>(
      reducer: SearchViewModel.StoreReducer()
  )
  let disposeBag = DisposeBag()

  deinit {
    Dispatcher.shared.unregister(identifier: store.identifier)
  }
}

// MARK: - Lifecycle

extension SearchViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()

    Dispatcher.shared.dispatch(action: SearchViewModel.Action.cancel)
  }

  func setup() {
    self.addChildVCs()
    self.bindStore()
    self.bindSearchBar()
    Dispatcher.shared.register(store: store)
  }

}

// MARK: - 検索バー関連

extension SearchViewController: UISearchBarDelegate {

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    Dispatcher.shared.dispatch(action: SearchViewModel.Action.cancel)
    view.endEditing(true)
    searchBar.resignFirstResponder()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let keyword = searchBar.text {
      Dispatcher.shared.dispatch(action: SearchViewModel.Action.search(keyword: keyword))
    }
    view.endEditing(true)
    searchBar.resignFirstResponder()
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
  }
}

private extension SearchViewController {

  func addChildVCs() {
    self.addChildViewController(self.supplementalVC)
    self.supplementalVC.didMove(toParentViewController: self)
    self.addChildViewController(self.albumCoverTableVC)
    self.albumCoverTableVC.didMove(toParentViewController: self)
  }

  // MARK: - SearchBar <--> ViewController
  func bindSearchBar() {
    let searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.autocorrectionType = .no
    searchBar.autocapitalizationType = .none
    searchBar.showsCancelButton = false
    self.navigationItem.titleView = searchBar
  }

  // MARK: - View <--> Store binding
  func bindStore() {
    self.supplementalVC.bind(state: store.state)
    self.albumCoverTableVC.bind(state: store.state)

    // searchStateのシグナルに応じてTableViewとその他状態のViewを切り替える
    store
        .state
        .searchState
        .asObservable()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] state in
          switch state {
          case .done:
            self?.containerView.fill(with: self?.albumCoverTableVC.view)
          default:
            self?.containerView.fill(with: self?.supplementalVC.view)
          }
        }).addDisposableTo(self.disposeBag)
  }

}
