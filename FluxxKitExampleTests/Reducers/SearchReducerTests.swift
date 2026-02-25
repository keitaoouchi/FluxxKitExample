import Testing
@testable import FluxxKitExample
import FluxxKit

@Suite("Search Reducer")
struct SearchReducerTests {

    @Test func searchTransitionsToSearching() {
        let state = SearchState()
        let (newState, effect) = searchReducer.reduce(state, .search(keyword: "test"), .unused)
        #expect(newState.phase == .searching)
        if case .none = effect {
            Issue.record("Expected .run effect")
        }
    }

    @Test func loadedWithAlbumsTransitionsToLoaded() {
        var state = SearchState()
        state.phase = .searching
        let albums = [
            Album(id: "1", type: "album", title: "Test", images: [], artists: [], url: "", externalUrls: nil)
        ]
        let (newState, _) = searchReducer.reduce(state, .loaded(albums), .unused)
        #expect(newState.phase == .loaded)
        #expect(newState.albums.count == 1)
    }

    @Test func loadedWithEmptyTransitionsToEmpty() {
        var state = SearchState()
        state.phase = .searching
        let (newState, _) = searchReducer.reduce(state, .loaded([]), .unused)
        #expect(newState.phase == .empty)
        #expect(newState.albums.isEmpty)
    }

    @Test func failedTransitionsToFailed() {
        var state = SearchState()
        state.phase = .searching
        let (newState, _) = searchReducer.reduce(state, .failed, .unused)
        #expect(newState.phase == .failed)
    }

    @Test func resetReturnsInitialState() {
        var state = SearchState()
        state.phase = .loaded
        state.albums = [
            Album(id: "1", type: "album", title: "Test", images: [], artists: [], url: "", externalUrls: nil)
        ]
        let (newState, _) = searchReducer.reduce(state, .reset, .unused)
        #expect(newState.phase == .idle)
        #expect(newState.albums.isEmpty)
    }
}
