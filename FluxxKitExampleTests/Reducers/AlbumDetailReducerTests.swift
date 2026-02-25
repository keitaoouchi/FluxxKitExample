import Testing
@testable import FluxxKitExample
import FluxxKit

@Suite("AlbumDetail Reducer")
struct AlbumDetailReducerTests {

    @Test func fetchTracksTransitionsToLoading() {
        let state = AlbumDetailState()
        let (newState, effect) = albumDetailReducer.reduce(state, .fetchTracks(albumId: "123"))
        #expect(newState.phase == .loading)
        if case .none = effect {
            Issue.record("Expected .run effect")
        }
    }

    @Test func loadedWithTracksTransitionsToLoaded() {
        var state = AlbumDetailState()
        state.phase = .loading
        let tracks = [
            Track(id: "1", name: "Track 1", trackNumber: 1, previewUrl: nil, durationMs: 200000, album: nil)
        ]
        let (newState, _) = albumDetailReducer.reduce(state, .loaded(tracks))
        #expect(newState.phase == .loaded)
        #expect(newState.tracks.count == 1)
    }

    @Test func loadedWithEmptyTransitionsToEmpty() {
        var state = AlbumDetailState()
        state.phase = .loading
        let (newState, _) = albumDetailReducer.reduce(state, .loaded([]))
        #expect(newState.phase == .empty)
    }

    @Test func failedTransitionsToFailed() {
        var state = AlbumDetailState()
        state.phase = .loading
        let (newState, _) = albumDetailReducer.reduce(state, .failed)
        #expect(newState.phase == .failed)
    }
}
