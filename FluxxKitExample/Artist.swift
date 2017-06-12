import Himotoki
import RxSwift
import Just

struct Artist {
  let id: String
  let name: String
  let url: String
  let spotifyUrl: String?
  let images: [Image]?
}

extension Artist: Decodable {
  static func decode(_ e: Extractor) throws -> Artist {
    return try Artist(
        id: e <| "id",
        name: e <| "name",
        url: e <| "href",
        spotifyUrl: e <|? ["external_urls", "spotify"],
        images: e <||? "images"
    )
  }
}

// MARK: - API Request

extension Artist {

  static func fetchRelatedArtists(for artist: Artist) -> Observable<[Artist]> {
    return Observable.create { observer in
      let url = "\(artist.url)/related-artists"
      let req = Just.get(url, headers: Authentication.shared.requestHeader) { r in
        if r.ok {
          if let json = r.json,
             let artists: [Artist] = try? decodeArray(json, rootKeyPath: "artists") {
            observer.onNext(artists)
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

  func getImages() -> Observable<[Image]> {
    return Observable.create { observer in
      let req = Just.get(self.url, headers: Authentication.shared.requestHeader) { r in
        if r.ok {
          if let json = r.json,
             let images: [Image] = try? decodeArray(json, rootKeyPath: "images") {
            observer.onNext(images)
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
