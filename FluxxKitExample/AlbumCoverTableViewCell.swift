import UIKit
import Kingfisher

class AlbumCoverTableViewCell: UITableViewCell {
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var albumTitle: UILabel!
  @IBOutlet weak var coverImageView: UIImageView!
}

extension AlbumCoverTableViewCell {
  func apply(album: Album) {
    if let urlStr = album.images.first?.url, let url = URL(string: urlStr) {
      coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
    albumTitle.text = album.title
    artistName.text = album.artists.first?.name
  }
}
