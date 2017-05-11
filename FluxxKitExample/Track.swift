import Himotoki
import RxSwift
import Just

struct Track {
  let id: String
  let name: String
  let trackNumber: Int
  let previewUrl: String
  let durationMs: Int
  var album: Album?

  func duration() -> Duration {
    return Duration(intervalSeconds: durationMs / 1000)
  }

  struct Duration: CustomStringConvertible {
    let hours: Int
    let minutes: Int
    let seconds: Int

    init(intervalSeconds: Int) {
      hours = Int(intervalSeconds) / 3600
      minutes = Int(intervalSeconds / 60) % 60
      seconds = Int(intervalSeconds) % 60
    }

    var description: String {
      if hours > 0 {
        return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
      } else {
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
      }
    }

  }

}

extension Track: Decodable {
  static func decode(_ e: Extractor) throws -> Track {
    return try Track(
        id: e <| "id",
        name: e <| "name",
        trackNumber: e <| "track_number",
        previewUrl: e <| "preview_url",
        durationMs: e <| "duration_ms",
        album: nil
    )
  }
}

// MARK: - API Request

extension Track {
  static func getAll(from album: Album) -> Observable<[Track]> {
    return Observable.create { observer in
      let url = "https://api.spotify.com/v1/albums/\(album.id)"
      let req = Just.get(url) { r in
        if r.ok {
          if let json = r.json,
             let tracks: [Track] = try? decodeArray(json, rootKeyPath: ["tracks", "items"]) {
            observer.onNext(tracks)
            observer.onCompleted()
          } else {
            observer.onError(APIError.parseError)
          }
        } else {
          observer.onError(APIError.requestError)
        }
      }
      return Disposables.create { req.cancel() }
    }
  }
}
