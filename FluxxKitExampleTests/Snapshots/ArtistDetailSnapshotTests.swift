import Testing
import SwiftUI
import SnapshotTesting
import FluxxKit
@testable import FluxxKitExample

@Suite("ArtistDetail Snapshot Tests")
@MainActor
struct ArtistDetailSnapshotTests {

    let artist = SnapshotFixture.mockArtist()

    @Test func testLoading() {
        let state = ArtistDetailState()
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testAllLoaded() {
        var state = ArtistDetailState()
        state.images = SnapshotFixture.mockImages()
        state.imagesPhase = .loaded
        state.albums = SnapshotFixture.mockAlbums()
        state.singles = SnapshotFixture.mockSingles()
        state.releasesPhase = .loaded
        state.relatedArtists = SnapshotFixture.mockRelatedArtists()
        state.relatedArtistsPhase = .loaded
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testAlbumsAndSingles() {
        var state = ArtistDetailState()
        state.imagesPhase = .loaded
        state.albums = SnapshotFixture.mockAlbums()
        state.singles = SnapshotFixture.mockSingles()
        state.releasesPhase = .loaded
        state.relatedArtistsPhase = .loaded
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testRelatedArtistsOnly() {
        var state = ArtistDetailState()
        state.imagesPhase = .loaded
        state.releasesPhase = .loaded
        state.relatedArtists = SnapshotFixture.mockRelatedArtists()
        state.relatedArtistsPhase = .loaded
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testImagesOnly() {
        var state = ArtistDetailState()
        state.images = SnapshotFixture.mockImages()
        state.imagesPhase = .loaded
        state.releasesPhase = .loaded
        state.relatedArtistsPhase = .loaded
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }

    @Test func testAllFailed() {
        var state = ArtistDetailState()
        state.imagesPhase = .failed
        state.releasesPhase = .failed
        state.relatedArtistsPhase = .failed
        let store = makeArtistDetailStore(state: state)
        let view = NavigationStack {
            ArtistDetailView(artist: artist, store: store)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13),

        )
    }
}
