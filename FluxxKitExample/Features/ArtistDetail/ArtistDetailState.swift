import FluxxKit

struct ArtistDetailState: StateType {
    var images: [SpotifyImage] = []
    var albums: [Album] = []
    var singles: [Album] = []
    var relatedArtists: [Artist] = []

    var imagesPhase: Phase = .loading
    var releasesPhase: Phase = .loading
    var relatedArtistsPhase: Phase = .loading

    enum Phase: Sendable {
        case loading
        case loaded
        case empty
        case failed
    }
}

enum ArtistDetailAction: ActionType {
    case fetchAll(artist: Artist)
    case imagesLoaded([SpotifyImage])
    case imagesFailed
    case releasesLoaded([Album])
    case releasesFailed
    case relatedArtistsLoaded([Artist])
    case relatedArtistsFailed
}

let artistDetailReducer = Reducer<ArtistDetailState, ArtistDetailAction> { state, action in
    switch action {
    case .fetchAll(let artist):
        var s = state
        s.imagesPhase = .loading
        s.releasesPhase = .loading
        s.relatedArtistsPhase = .loading
        return (s, .many([
            .run { dispatch in
                do {
                    let images = try await SpotifyAPI.fetchArtistImages(
                        artistUrl: artist.url,
                        authentication: Authentication()
                    )
                    await dispatch(images.isEmpty ? .imagesFailed : .imagesLoaded(images))
                } catch {
                    await dispatch(.imagesFailed)
                }
            },
            .run { dispatch in
                do {
                    let releases = try await SpotifyAPI.fetchAlbumsByArtist(
                        artistUrl: artist.url,
                        authentication: Authentication()
                    )
                    await dispatch(releases.isEmpty ? .releasesFailed : .releasesLoaded(releases))
                } catch {
                    await dispatch(.releasesFailed)
                }
            },
            .run { dispatch in
                do {
                    let artists = try await SpotifyAPI.fetchRelatedArtists(
                        artistUrl: artist.url,
                        authentication: Authentication()
                    )
                    await dispatch(artists.isEmpty ? .relatedArtistsFailed : .relatedArtistsLoaded(artists))
                } catch {
                    await dispatch(.relatedArtistsFailed)
                }
            },
        ]))
    case .imagesLoaded(let images):
        var s = state
        s.images = images
        s.imagesPhase = .loaded
        return (s, .none)
    case .imagesFailed:
        var s = state
        s.imagesPhase = .failed
        return (s, .none)
    case .releasesLoaded(let releases):
        var s = state
        s.albums = releases.filter { $0.type == "album" }
        s.singles = releases.filter { $0.type == "single" }
        s.releasesPhase = .loaded
        return (s, .none)
    case .releasesFailed:
        var s = state
        s.releasesPhase = .failed
        return (s, .none)
    case .relatedArtistsLoaded(let artists):
        var s = state
        s.relatedArtists = artists
        s.relatedArtistsPhase = .loaded
        return (s, .none)
    case .relatedArtistsFailed:
        var s = state
        s.relatedArtistsPhase = .failed
        return (s, .none)
    }
}
