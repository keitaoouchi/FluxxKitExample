import Testing
import Foundation
@testable import FluxxKitExample

@Suite("Album Decoding")
struct AlbumDecodingTests {

    private struct SearchResponse: Codable {
        let albums: AlbumsPaging
        struct AlbumsPaging: Codable {
            let items: [Album]
        }
    }

    @Test func decodesSearchResult() throws {
        let data = try TestFixture.loadJSON("search_result.json")
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        let albums = response.albums.items
        #expect(!albums.isEmpty)
        let first = albums[0]
        #expect(first.id == "49MNmJhZQewjt06rpwp6QR")
        #expect(first.title == "Mezzanine")
        #expect(first.type == "album")
        #expect(!first.images.isEmpty)
        #expect(!first.artists.isEmpty)
        #expect(first.artists[0].name == "Massive Attack")
        #expect(first.externalUrls?.spotify != nil)
    }

    @Test func decodesAlbumDetail() throws {
        let data = try TestFixture.loadJSON("album.json")
        let album = try JSONDecoder().decode(Album.self, from: data)
        #expect(album.id == "49MNmJhZQewjt06rpwp6QR")
        #expect(album.title == "Mezzanine")
        #expect(album.type == "album")
        #expect(album.images.count == 3)
    }

    @Test func decodesReleasesItems() throws {
        let data = try TestFixture.loadJSON("releases.json")
        struct ReleasesResponse: Codable {
            let items: [Album]
        }
        let response = try JSONDecoder().decode(ReleasesResponse.self, from: data)
        #expect(!response.items.isEmpty)
        let types = Set(response.items.map(\.type))
        #expect(types.contains("album"))
    }
}
