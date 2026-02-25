import Testing
import SwiftUI
import SnapshotTesting
import FluxxKit
@testable import FluxxKitExample

@Suite("AlbumDetail Snapshot Tests")
@MainActor
struct AlbumDetailSnapshotTests {

    let album = SnapshotFixture.mockAlbum()

    @Test func testLoading() {
        let state = AlbumDetailState()
        let store = makeAlbumDetailStore(state: state)
        let trackPlayerStore = makeTrackPlayerStore()
        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testLoaded() {
        var state = AlbumDetailState()
        state.phase = .loaded
        state.tracks = SnapshotFixture.mockTracks()
        let store = makeAlbumDetailStore(state: state)
        let trackPlayerStore = makeTrackPlayerStore()
        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testEmpty() {
        var state = AlbumDetailState()
        state.phase = .empty
        let store = makeAlbumDetailStore(state: state)
        let trackPlayerStore = makeTrackPlayerStore()
        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testFailed() {
        var state = AlbumDetailState()
        state.phase = .failed
        let store = makeAlbumDetailStore(state: state)
        let trackPlayerStore = makeTrackPlayerStore()
        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testPlayingTrack() {
        var state = AlbumDetailState()
        state.phase = .loaded
        state.tracks = SnapshotFixture.mockTracks()
        let store = makeAlbumDetailStore(state: state)

        let tracks = SnapshotFixture.mockTracks()
        var playerState = TrackPlayerState()
        playerState.currentTrack = tracks[0]
        playerState.playerPhase = .playing
        playerState.visibility = .showing
        let trackPlayerStore = makeTrackPlayerStore(state: playerState)

        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testPausedTrack() {
        var state = AlbumDetailState()
        state.phase = .loaded
        state.tracks = SnapshotFixture.mockTracks()
        let store = makeAlbumDetailStore(state: state)

        let tracks = SnapshotFixture.mockTracks()
        var playerState = TrackPlayerState()
        playerState.currentTrack = tracks[0]
        playerState.playerPhase = .paused
        playerState.visibility = .showing
        let trackPlayerStore = makeTrackPlayerStore(state: playerState)

        let view = NavigationStack {
            AlbumDetailView(album: album, store: store)
        }
        .environment(trackPlayerStore)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }
}
