import UIKit

class RelatedArtistCollectionViewController: UICollectionViewController {
  var artists: [Artist] = []
}

// MARK: - UICollection data source

extension RelatedArtistCollectionViewController {

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return artists.count
  }
}

// MARK: - UICollection delegate

extension RelatedArtistCollectionViewController {

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // swiftlint:disable:next force_cast
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! RelatedArtistCollectionViewCell
    let artist = artists[indexPath.row]
    cell.apply(artist: artist)
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // swiftlint:disable:next force_unwrapping
    let vc = R.storyboard.artistDetail.instantiateInitialViewController()!
    let artist = artists[indexPath.row]
    vc.artist = artist
    navigationController?.pushViewController(vc, animated: true)
  }
}
