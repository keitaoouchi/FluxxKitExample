import FBSnapshotTestCase
import Himotoki
import FluxxKit
@testable import FluxxKitExample

// swiftlint:disable identifier_name
// swiftlint:disable force_cast
// swiftlint:disable force_try
final class SearchSnapshotTests: FBSnapshotTestCase {

  var vc: SearchViewController!

  override func setUp() {
    super.setUp()
    self.recordMode = false

    let nav = UIStoryboard(
        name: "Search",
        bundle: nil
    ).instantiateInitialViewController() as! UINavigationController
    vc = nav.topViewController as! SearchViewController
    vc.loadViewIfNeeded()
    vc.setup()
  }

  func testInit() {
    Dispatcher.shared.dispatch(action: SearchViewModel.Action.transition(state: .initial))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testEmpty() {
    Dispatcher.shared.dispatch(action: SearchViewModel.Action.transition(state: .empty))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testFailed() {
    Dispatcher.shared.dispatch(action: SearchViewModel.Action.transition(state: .failed(error: TestHelper.error)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(vc.view)
  }

  func testDone() {
    let json = TestHelper.load(json: "search_result")
    let albums: [Album] = try! decodeArray(json, rootKeyPath: ["albums", "items"])
    Dispatcher.shared.dispatch(action: SearchViewModel.Action.transition(state: .done(albums: albums)))
    TestHelper.wait(for: 2.0)
    FBSnapshotVerifyView(vc.view)
  }

}
