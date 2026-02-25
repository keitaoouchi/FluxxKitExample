import Testing
import SwiftUI
import SnapshotTesting
import FluxxKit
@testable import FluxxKitExample

@Suite("Search Snapshot Tests")
@MainActor
struct SearchSnapshotTests {

    @Test func testIdle() {
        let state = SearchState()
        let store = makeSearchStore(state: state)
        let view = SearchView(store: store)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testSearching() {
        var state = SearchState()
        state.phase = .searching
        let store = makeSearchStore(state: state)
        let view = SearchView(store: store)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testLoaded() {
        var state = SearchState()
        state.phase = .loaded
        state.albums = SnapshotFixture.mockAlbums()
        let store = makeSearchStore(state: state)
        let view = SearchView(store: store)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testEmpty() {
        var state = SearchState()
        state.phase = .empty
        let store = makeSearchStore(state: state)
        let view = SearchView(store: store)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testFailed() {
        var state = SearchState()
        state.phase = .failed
        let store = makeSearchStore(state: state)
        let view = SearchView(store: store)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }
}
