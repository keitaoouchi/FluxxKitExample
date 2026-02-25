import Foundation
import FluxxKit
@testable import FluxxKitExample

// MARK: - No-op Reducers

/// A reducer that returns the state unchanged and produces no effects.
/// Used in snapshot tests to prevent `.onAppear` dispatches from modifying state.
let noOpSearchReducer = LocalReducer<SearchState, SearchAction> { state, _ in
    (state, .none)
}

let noOpAlbumDetailReducer = LocalReducer<AlbumDetailState, AlbumDetailAction> { state, _ in
    (state, .none)
}

let noOpArtistDetailReducer = LocalReducer<ArtistDetailState, ArtistDetailAction> { state, _ in
    (state, .none)
}

let noOpTrackPlayerReducer = LocalReducer<TrackPlayerState, TrackPlayerAction> { state, _ in
    (state, .none)
}

// MARK: - Fixture Helpers

@MainActor
enum SnapshotFixture {
    static func mockAlbum() -> Album {
        Album(
            id: "49MNmJhZQewjt06rpwp6QR",
            type: "album",
            title: "Mezzanine",
            images: [
                SpotifyImage(url: "https://i.scdn.co/image/fb9b24b7060cc4f8b72cf25c0b35fb9661b1230b", height: 640, width: 640)
            ],
            artists: [mockArtist()],
            url: "https://api.spotify.com/v1/albums/49MNmJhZQewjt06rpwp6QR",
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/album/49MNmJhZQewjt06rpwp6QR")
        )
    }

    static func mockAlbums() -> [Album] {
        [
            mockAlbum(),
            Album(
                id: "1X4zW7kIY8bQHO9gDTsIVh",
                type: "album",
                title: "Collected",
                images: [
                    SpotifyImage(url: "https://i.scdn.co/image/7ad5b0790b55f9864f8e524a4ae6d08e7ef4a962", height: 640, width: 640)
                ],
                artists: [mockArtist()],
                url: "https://api.spotify.com/v1/albums/1X4zW7kIY8bQHO9gDTsIVh",
                externalUrls: ExternalUrls(spotify: "https://open.spotify.com/album/1X4zW7kIY8bQHO9gDTsIVh")
            ),
            Album(
                id: "1F8y2bg9V9nRoy8zuxo3Jt",
                type: "album",
                title: "Heligoland",
                images: [
                    SpotifyImage(url: "https://i.scdn.co/image/9c021dffa4400f14d5639f8361b9456042062aa7", height: 640, width: 640)
                ],
                artists: [mockArtist()],
                url: "https://api.spotify.com/v1/albums/1F8y2bg9V9nRoy8zuxo3Jt",
                externalUrls: ExternalUrls(spotify: "https://open.spotify.com/album/1F8y2bg9V9nRoy8zuxo3Jt")
            ),
        ]
    }

    static func mockSingles() -> [Album] {
        [
            Album(
                id: "6Y0Bxavb5HMH8SZww9G9SL",
                type: "single",
                title: "The Spoils",
                images: [
                    SpotifyImage(url: "https://i.scdn.co/image/35b73726143bd04cf0eb5f16acb49feee18b6a75", height: 640, width: 640)
                ],
                artists: [mockArtist()],
                url: "https://api.spotify.com/v1/albums/6Y0Bxavb5HMH8SZww9G9SL",
                externalUrls: ExternalUrls(spotify: "https://open.spotify.com/album/6Y0Bxavb5HMH8SZww9G9SL")
            ),
        ]
    }

    static func mockArtist() -> Artist {
        Artist(
            id: "6FXMGgJwohJLUSr5nVlf9X",
            name: "Massive Attack",
            url: "https://api.spotify.com/v1/artists/6FXMGgJwohJLUSr5nVlf9X",
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/artist/6FXMGgJwohJLUSr5nVlf9X"),
            images: [
                SpotifyImage(url: "https://i.scdn.co/image/fb9b24b7060cc4f8b72cf25c0b35fb9661b1230b", height: 640, width: 640)
            ]
        )
    }

    static func mockRelatedArtists() -> [Artist] {
        [
            Artist(
                id: "artist1",
                name: "Portishead",
                url: "https://api.spotify.com/v1/artists/artist1",
                externalUrls: ExternalUrls(spotify: "https://open.spotify.com/artist/artist1"),
                images: [SpotifyImage(url: "https://i.scdn.co/image/fb9b24b7060cc4f8b72cf25c0b35fb9661b1230b", height: 640, width: 640)]
            ),
            Artist(
                id: "artist2",
                name: "Tricky",
                url: "https://api.spotify.com/v1/artists/artist2",
                externalUrls: ExternalUrls(spotify: "https://open.spotify.com/artist/artist2"),
                images: [SpotifyImage(url: "https://i.scdn.co/image/7ad5b0790b55f9864f8e524a4ae6d08e7ef4a962", height: 640, width: 640)]
            ),
        ]
    }

    static func mockTracks() -> [Track] {
        [
            Track(id: "7uv632EkfwYhXoqf8rhYrg", name: "Angel", trackNumber: 1, previewUrl: "https://p.scdn.co/mp3-preview/d8d069e27fd103a2fbb34fe9932dcbba686e31e1", durationMs: 379533, album: nil),
            Track(id: "6ggJ6MceyHGWtUg1KLp3M1", name: "Risingson", trackNumber: 2, previewUrl: "https://p.scdn.co/mp3-preview/5ab45588f3c908f2aa8653f2f11dc80896d60cc6", durationMs: 298826, album: nil),
            Track(id: "67Hna13dNDkZvBpTXRIaOJ", name: "Teardrop", trackNumber: 3, previewUrl: "https://p.scdn.co/mp3-preview/7b9c22dbd27bd948cb6a515bb79c19f1e73ffe1d", durationMs: 330773, album: nil),
            Track(id: "3N2UhXZI4Gf64Ku3cCjz2g", name: "Inertia Creeps", trackNumber: 4, previewUrl: "https://p.scdn.co/mp3-preview/05d469e1126d7a765bc4d14ecf05de6890d7571d", durationMs: 357133, album: nil),
            Track(id: "2HuMQkNVpFIsur2cRWWQmX", name: "Exchange", trackNumber: 5, previewUrl: nil, durationMs: 251200, album: nil),
        ]
    }

    static func mockImages() -> [SpotifyImage] {
        [
            SpotifyImage(url: "https://i.scdn.co/image/fb9b24b7060cc4f8b72cf25c0b35fb9661b1230b", height: 640, width: 640),
            SpotifyImage(url: "https://i.scdn.co/image/8b923b9f2ddf641d57b6fbeae3656eb4b71c636d", height: 300, width: 300),
        ]
    }
}

// MARK: - Store Helpers

@MainActor
func makeSearchStore(state: SearchState) -> Store<SearchState, SearchAction> {
    Store(initialState: state, reducer: noOpSearchReducer)
}

@MainActor
func makeAlbumDetailStore(state: AlbumDetailState) -> Store<AlbumDetailState, AlbumDetailAction> {
    Store(initialState: state, reducer: noOpAlbumDetailReducer)
}

@MainActor
func makeArtistDetailStore(state: ArtistDetailState) -> Store<ArtistDetailState, ArtistDetailAction> {
    Store(initialState: state, reducer: noOpArtistDetailReducer)
}

@MainActor
func makeTrackPlayerStore(state: TrackPlayerState = TrackPlayerState()) -> Store<TrackPlayerState, TrackPlayerAction> {
    Store(initialState: state, reducer: noOpTrackPlayerReducer)
}
