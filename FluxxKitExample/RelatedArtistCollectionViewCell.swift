import UIKit
import Kingfisher

class RelatedArtistCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var artistNameLabel: UILabel!
}

extension RelatedArtistCollectionViewCell {
  func apply(artist: Artist) {
    if let urlStr = artist.images?.first?.url, let url = URL(string: urlStr) {
      imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
      artistNameLabel.text = artist.name
    }
  }
}
