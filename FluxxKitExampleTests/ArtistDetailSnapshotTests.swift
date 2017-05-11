import FBSnapshotTestCase
import Himotoki
import FluxxKit
@testable import FluxxKitExample

// swiftlint:disable identifier_name
// swiftlint:disable force_cast
// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
final class ArtistDetailSnapshotTests: FBSnapshotTestCase {

  var vc: ArtistDetailViewController!

  override func setUp() {
    super.setUp()
    self.recordMode = false
    Dispatcher.shared.unregister(middleware: ArtistDetailViewModel.ThunkMiddleware.self)

    vc = UIStoryboard(
        name: "ArtistDetail",
        bundle: nil
    ).instantiateInitialViewController() as! ArtistDetailViewController
    let json = TestHelper.load(json: "artist")
    let artist: Artist = try! decodeValue(json)
    vc.artist = artist
    vc.loadViewIfNeeded()
  }

}

// MARK: - アーティスト画像
extension ArtistDetailSnapshotTests {

  func testRequestingImages() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .image(state: .requesting)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testDoneImages() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .image(state: .done(images: vc.artist.images!))))
    TestHelper.wait(for: 1.0, view: vc.view)
    FBSnapshotVerifyView(vc.view)
  }

  func testEmptyImages() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .image(state: .empty)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testFailedImages() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .image(state: .failed(error: TestHelper.error))))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }
}

// MARK: - リリース
extension ArtistDetailSnapshotTests {

  func testRequestingReleases() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .albums(state: .requesting)))
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .singles(state: .requesting)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testDoneReleases() {
    let json = TestHelper.load(json: "releases")
    let releases: [Album] = try! decodeArray(json, rootKeyPath: "items")
    let albums = releases.filter { $0.type == "album" }
    let singles = releases.filter { $0.type == "single" }
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .albums(state: .done(albums: albums))))
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .singles(state: .done(singles: singles))))
    TestHelper.wait(for: 1.0, view: vc.view)
    FBSnapshotVerifyView(vc.view)
  }

  func testEmptyReleases() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .albums(state: .empty)))
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .singles(state: .empty)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testFailedReleases() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .albums(state: .failed(error: TestHelper.error))))
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .singles(state: .failed(error: TestHelper.error))))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }
}

// MARK: - 関連アーティスト
extension ArtistDetailSnapshotTests {

  func testRequestingRelatedArtists() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .relatedArtists(state: .requesting)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testDoneRelatedArtists() {
    let json = TestHelper.load(json: "related_artists")
    let artists: [Artist] = try! decodeArray(json, rootKeyPath: "artists")
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .relatedArtists(state: .done(artists: artists))))
    TestHelper.wait(for: 1.0, view: vc.view)
    FBSnapshotVerifyView(vc.view)
  }

  func testEmptyRelatedArtists() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .relatedArtists(state: .empty)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testFailedRelatedArtists() {
    Dispatcher.shared.dispatch(action: ArtistDetailViewModel.Action.transition(type: .relatedArtists(state: .failed(error: TestHelper.error))))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

}
