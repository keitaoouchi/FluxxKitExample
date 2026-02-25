import Foundation

struct Artist: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let externalUrls: ExternalUrls?
    let images: [SpotifyImage]?

    enum CodingKeys: String, CodingKey {
        case id, name, images
        case url = "href"
        case externalUrls = "external_urls"
    }
}
