import UIKit
import RxSwift

class AlbumCardViewController: UITableViewController {
  var albums: [Album] = []
  var disposeBag = DisposeBag()
}

// MARK: - Lifecycle

extension AlbumCardViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func bind(state: SearchViewModel) {
    state.searchState.asObservable().observeOn(
        MainScheduler.instance
    ).subscribe(onNext: { [weak self] state in
      if case .done(let albums) = state {
        self?.albums = albums
        self?.tableView.reloadData()
      }
    }).addDisposableTo(self.disposeBag)
  }
}

// MARK: - Table view data source

extension AlbumCardViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.albums.count
  }
}

// MARK: - Table view delegate

extension AlbumCardViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // swiftlint:disable:next force_cast
    let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCoverCell") as! AlbumCoverTableViewCell
    let album = self.albums[indexPath.row]
    cell.apply(album: album)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // swiftlint:disable:next force_unwrapping
    let vc = R.storyboard.albumDetail.instantiateInitialViewController()!
    let album = albums[indexPath.row]
    vc.album = album
    navigationController?.pushViewController(vc, animated: true)
  }
}
