import UIKit
import RxSwift
import FluxxKit

final class TrackTableViewController: UITableViewController {
  var album: Album?
  var tracks: [Track] = []
  var playingTrack: Track?
  var onLoad: (() -> Void)?
  let disposeBag = DisposeBag()
}

// MARK: - Lifecycle

extension TrackTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension TrackTableViewController {

  func bind(state: AlbumDetailViewModel) {
    state.requestState.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] state in
      if case .done(let tracks) = state {
        self?.tracks = tracks
        self?.tableView.reloadData()
        self?.onLoad?()
      }
    }).addDisposableTo(self.disposeBag)
  }

  func bind(state: TrackPlayerViewModel) {
    let trackStream = state.trackStream.asObservable()
    let playerState = state.playerState.asObservable()

    Observable
      .combineLatest(trackStream, playerState)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] track, playerState in
        var rows: [IndexPath] = []
        if let previousTrack = self?.playingTrack, let index = self?.tracks.index(where: { track in previousTrack.id == track.id }) {
          rows.append(IndexPath(row: index, section: 0))
        }
        switch playerState {
        case .playing:
          self?.playingTrack = track
        default:
          self?.playingTrack = nil
        }
        if let currentTrack = self?.playingTrack, let index = self?.tracks.index(where: { track in currentTrack.id == track.id }) {
          rows.append(IndexPath(row: index, section: 0))
        }
        self?.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.automatic)
      }).addDisposableTo(self.disposeBag)
  }
}

// MARK: - Table view data source

extension TrackTableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }

}

// MARK: - Table view delegate

extension TrackTableViewController {

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // swiftlint:disable:next force_cast
    let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
    let track = tracks[indexPath.row]
    let isPlaying: Bool
    if let playingTrack = playingTrack, track.id == playingTrack.id {
      isPlaying = true
    } else {
      isPlaying = false
    }
    cell.apply(track: track, isPlaying: isPlaying)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var track = tracks[indexPath.row]
    track.album = album
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.show)
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.toggle(track: track))
  }
}
