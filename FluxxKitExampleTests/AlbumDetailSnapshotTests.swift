import FBSnapshotTestCase
import Himotoki
import FluxxKit
@testable import FluxxKitExample

// swiftlint:disable identifier_name
// swiftlint:disable force_cast
// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
final class AlbumDetailSnapshotTests: FBSnapshotTestCase {

  var vc: AlbumDetailViewController!

  override func setUp() {
    super.setUp()
    self.recordMode = false
    Dispatcher.shared.unregister(middleware: AlbumDetailViewModel.AsyncMiddleware.self)

    vc = UIStoryboard(
        name: "AlbumDetail",
        bundle: nil
    ).instantiateInitialViewController() as! AlbumDetailViewController
    let json = TestHelper.load(json: "album")
    let album: Album = try! decodeValue(json)
    vc.album = album
    vc.loadViewIfNeeded()
    vc.addTrackPlayerView()
    vc.trackPlayerVC.store.state.player.volume = 0.0
    Dispatcher.shared.dispatch( action: TrackPlayerViewModel.Action.stop)
    Dispatcher.shared.dispatch( action: TrackPlayerViewModel.Action.hide)
  }

  override func tearDown() {
    vc.removeTrackPlayerView()
  }

  func testRequesting() {
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .requesting))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testEmpty() {
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .empty))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testFailed() {
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .failed(error: TestHelper.error)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testDone() {
    let json = TestHelper.load(json: "album")
    let tracks: [Track] = try! decodeArray(json, rootKeyPath: ["tracks", "items"])
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .done(tracks: tracks)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testPlayingTrack() {
    let json = TestHelper.load(json: "album")
    let album: Album = try! decodeValue(json)
    let tracks: [Track] = try! decodeArray(json, rootKeyPath: ["tracks", "items"])
    var track = tracks.first!
    track.album = album
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .done(tracks: tracks)))
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.show)
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.play(track: track))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testStoppedTrack() {
    let json = TestHelper.load(json: "album")
    let album: Album = try! decodeValue(json)
    let tracks: [Track] = try! decodeArray(json, rootKeyPath: ["tracks", "items"])
    var track = tracks.first!
    track.album = album
    Dispatcher.shared.dispatch(action: AlbumDetailViewModel.Action.transition(state: .done(tracks: tracks)))
    Dispatcher.shared.dispatch( action: TrackPlayerViewModel.Action.show)
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.play(track: track))
    Dispatcher.shared.dispatch(action: TrackPlayerViewModel.Action.pause)
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

}
