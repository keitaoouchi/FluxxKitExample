import Foundation

struct Track: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let trackNumber: Int
    let previewUrl: String?
    let durationMs: Int
    var album: Album?

    enum CodingKeys: String, CodingKey {
        case id, name, album
        case trackNumber = "track_number"
        case previewUrl = "preview_url"
        case durationMs = "duration_ms"
    }

    var formattedDuration: String {
        let totalSeconds = durationMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
