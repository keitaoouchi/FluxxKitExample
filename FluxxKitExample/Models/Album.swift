import Foundation

struct Album: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let type: String
    let title: String
    let images: [SpotifyImage]
    let artists: [Artist]
    let url: String
    let externalUrls: ExternalUrls?

    enum CodingKeys: String, CodingKey {
        case id, images, artists
        case type = "album_type"
        case title = "name"
        case url = "href"
        case externalUrls = "external_urls"
    }
}
