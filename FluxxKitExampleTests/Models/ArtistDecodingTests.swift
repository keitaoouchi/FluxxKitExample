import Testing
import Foundation
@testable import FluxxKitExample

@Suite("Artist Decoding")
struct ArtistDecodingTests {

    @Test func decodesArtist() throws {
        let artist = try TestFixture.decode(Artist.self, from: "artist.json")
        #expect(artist.id == "6FXMGgJwohJLUSr5nVlf9X")
        #expect(artist.name == "Massive Attack")
        #expect(artist.images != nil)
        #expect(artist.images!.count == 4)
        #expect(artist.externalUrls?.spotify != nil)
    }

    @Test func decodesRelatedArtists() throws {
        let data = try TestFixture.loadJSON("related_artists.json")
        struct RelatedArtistsResponse: Codable {
            let artists: [Artist]
        }
        let response = try JSONDecoder().decode(RelatedArtistsResponse.self, from: data)
        #expect(!response.artists.isEmpty)
        #expect(response.artists[0].name == "Tricky")
    }
}
