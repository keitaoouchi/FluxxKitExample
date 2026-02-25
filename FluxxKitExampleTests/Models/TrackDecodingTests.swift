import Testing
import Foundation
@testable import FluxxKitExample

@Suite("Track Decoding")
struct TrackDecodingTests {

    private struct AlbumResponse: Codable {
        let tracks: TracksPaging
        struct TracksPaging: Codable {
            let items: [Track]
        }
    }

    @Test func decodesTracksFromAlbum() throws {
        let data = try TestFixture.loadJSON("album.json")
        let response = try JSONDecoder().decode(AlbumResponse.self, from: data)
        let tracks = response.tracks.items
        #expect(!tracks.isEmpty)
        let first = tracks[0]
        #expect(first.id == "7uv632EkfwYhXoqf8rhYrg")
        #expect(first.name == "Angel")
        #expect(first.trackNumber == 1)
        #expect(first.durationMs == 379533)
        #expect(first.previewUrl != nil)
    }

    @Test func formattedDuration() {
        let track = Track(
            id: "test",
            name: "Test",
            trackNumber: 1,
            previewUrl: nil,
            durationMs: 185000,
            album: nil
        )
        #expect(track.formattedDuration == "03:05")
    }
}
