import UIKit

class CoverCollectionViewController: UICollectionViewController {
  var albums: [Album] = []
}

// Lifecycle

extension CoverCollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

  }
}

// MARK: - UICollection data source

extension CoverCollectionViewController {

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return albums.count
  }
}

// MARK: - UICollection delegate

extension CoverCollectionViewController {

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // swiftlint:disable:next force_cast
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverCell", for: indexPath) as! CoverCollectionViewCell
    let album = albums[indexPath.row]
    cell.apply(album: album)
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // swiftlint:disable:next force_unwrapping
    let vc = R.storyboard.albumDetail.instantiateInitialViewController()!
    let album = albums[indexPath.row]
    vc.album = album
    navigationController?.pushViewController(vc, animated: true)
  }
}
