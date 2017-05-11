import UIKit
import Kingfisher

class CoverCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
}

extension CoverCollectionViewCell {
  func apply(album: Album) {
    if let urlStr = album.images.first?.url, let url = URL(string: urlStr) {
      imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
  }
}
