import Himotoki

struct Image {
  let url: String
  let height: Int
  let width: Int
}

extension Image: Himotoki.Decodable {
  static func decode(_ e: Extractor) throws -> Image {
    return try Image(url: e <| "url", height: e <| "height", width: e <| "width")
  }
}
