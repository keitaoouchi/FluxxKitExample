import Testing
@testable import FluxxKitExample
import FluxxKit

@Suite("ArtistDetail Reducer")
struct ArtistDetailReducerTests {

    @Test func fetchAllTransitionsToLoading() {
        let state = ArtistDetailState()
        let artist = Artist(id: "1", name: "Test", url: "https://api.spotify.com/v1/artists/1", externalUrls: nil, images: nil)
        let (newState, effect) = artistDetailReducer.reduce(state, .fetchAll(artist: artist), .unused)
        #expect(newState.imagesPhase == .loading)
        #expect(newState.releasesPhase == .loading)
        #expect(newState.relatedArtistsPhase == .loading)
        if case .none = effect {
            Issue.record("Expected .many effect")
        }
    }

    @Test func imagesLoadedUpdatesState() {
        let state = ArtistDetailState()
        let images = [SpotifyImage(url: "https://example.com/img.jpg", height: 640, width: 640)]
        let (newState, _) = artistDetailReducer.reduce(state, .imagesLoaded(images), .unused)
        #expect(newState.imagesPhase == .loaded)
        #expect(newState.images.count == 1)
    }

    @Test func releasesLoadedSplitsAlbumsAndSingles() {
        let state = ArtistDetailState()
        let releases = [
            Album(id: "1", type: "album", title: "Album 1", images: [], artists: [], url: "", externalUrls: nil),
            Album(id: "2", type: "single", title: "Single 1", images: [], artists: [], url: "", externalUrls: nil),
            Album(id: "3", type: "album", title: "Album 2", images: [], artists: [], url: "", externalUrls: nil),
        ]
        let (newState, _) = artistDetailReducer.reduce(state, .releasesLoaded(releases), .unused)
        #expect(newState.releasesPhase == .loaded)
        #expect(newState.albums.count == 2)
        #expect(newState.singles.count == 1)
    }

    @Test func relatedArtistsLoadedUpdatesState() {
        let state = ArtistDetailState()
        let artists = [Artist(id: "2", name: "Related", url: "", externalUrls: nil, images: nil)]
        let (newState, _) = artistDetailReducer.reduce(state, .relatedArtistsLoaded(artists), .unused)
        #expect(newState.relatedArtistsPhase == .loaded)
        #expect(newState.relatedArtists.count == 1)
    }

    @Test func imagesFailed() {
        let state = ArtistDetailState()
        let (newState, _) = artistDetailReducer.reduce(state, .imagesFailed, .unused)
        #expect(newState.imagesPhase == .failed)
    }

    @Test func releasesFailed() {
        let state = ArtistDetailState()
        let (newState, _) = artistDetailReducer.reduce(state, .releasesFailed, .unused)
        #expect(newState.releasesPhase == .failed)
    }

    @Test func relatedArtistsFailed() {
        let state = ArtistDetailState()
        let (newState, _) = artistDetailReducer.reduce(state, .relatedArtistsFailed, .unused)
        #expect(newState.relatedArtistsPhase == .failed)
    }
}
