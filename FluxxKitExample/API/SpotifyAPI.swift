import Foundation

enum SpotifyAPI: Sendable {
    private static let baseURL = "https://api.spotify.com/v1"

    // MARK: - Response Wrappers

    private struct SearchResponse: Codable {
        let albums: AlbumsPaging
    }

    private struct AlbumsPaging: Codable {
        let items: [Album]
    }

    private struct AlbumResponse: Codable {
        let tracks: TracksPaging
    }

    private struct TracksPaging: Codable {
        let items: [Track]
    }

    private struct ReleasesResponse: Codable {
        let items: [Album]
    }

    private struct RelatedArtistsResponse: Codable {
        let artists: [Artist]
    }

    // MARK: - API Methods

    @MainActor
    static func searchAlbums(keyword: String, authentication: Authentication) async throws -> [Album] {
        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? keyword
        let url = "\(baseURL)/search?q=\(encoded)&type=album&market=JP"
        let data = try await request(url: url, headers: authentication.requestHeader)
        let response = try decoder.decode(SearchResponse.self, from: data)
        return response.albums.items
    }

    @MainActor
    static func fetchTracks(albumId: String, authentication: Authentication) async throws -> [Track] {
        let url = "\(baseURL)/albums/\(albumId)"
        let data = try await request(url: url, headers: authentication.requestHeader)
        let response = try decoder.decode(AlbumResponse.self, from: data)
        return response.tracks.items
    }

    @MainActor
    static func fetchAlbumsByArtist(artistUrl: String, authentication: Authentication) async throws -> [Album] {
        let url = "\(artistUrl)/albums?album_type=album,single&market=JP"
        let data = try await request(url: url, headers: authentication.requestHeader)
        let response = try decoder.decode(ReleasesResponse.self, from: data)
        return response.items
    }

    @MainActor
    static func fetchRelatedArtists(artistUrl: String, authentication: Authentication) async throws -> [Artist] {
        let url = "\(artistUrl)/related-artists"
        let data = try await request(url: url, headers: authentication.requestHeader)
        let response = try decoder.decode(RelatedArtistsResponse.self, from: data)
        return response.artists
    }

    @MainActor
    static func fetchArtistImages(artistUrl: String, authentication: Authentication) async throws -> [SpotifyImage] {
        let data = try await request(url: artistUrl, headers: authentication.requestHeader)
        let artist = try decoder.decode(Artist.self, from: data)
        return artist.images ?? []
    }

    // MARK: - Private

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private static func request(url urlString: String, headers: [String: String]) async throws -> Data {
        guard let url = URL(string: urlString) else { throw APIError.requestError }
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.requestError }
        if httpResponse.statusCode == 401 { throw APIError.unauthorized }
        guard (200..<300).contains(httpResponse.statusCode) else { throw APIError.requestError }
        return data
    }
}
