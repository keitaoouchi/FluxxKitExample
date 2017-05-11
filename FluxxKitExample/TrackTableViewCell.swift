import UIKit
import IoniconsKit

class TrackTableViewCell: UITableViewCell {
  @IBOutlet weak var trackNumberLabel: UILabel!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
}

extension TrackTableViewCell {
  func apply(track: Track, isPlaying: Bool) {
    if isPlaying {
      trackNumberLabel.font = UIFont.ionicon(of: 14)
      trackNumberLabel.text = String.ionicon(with: .musicNote)
    } else {
      trackNumberLabel.font = UIFont.systemFont(ofSize: 14)
      trackNumberLabel.text = "\(track.trackNumber)"
    }
    trackNameLabel.text = track.name
    durationLabel.text = "\(track.duration())"
  }
}
