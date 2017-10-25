import RxSwift
import Just
import Himotoki

struct Album {
  let id: String
  let type: String
  let title: String
  let images: [Image]
  let artists: [Artist]
  let url: String
  let spotifyUrl: String?
}

extension Album: Himotoki.Decodable {
  static func decode(_ e: Extractor) throws -> Album {
    return try Album(
        id: e <| "id",
        type: e <| "album_type",
        title: e <| "name",
        images: e <|| "images",
        artists: e <|| "artists",
        url: e <| "href",
        spotifyUrl: e <|? ["external_urls", "spotify"]
    )
  }
}

// MARK: - API Request

extension Album {

  static func search(keyword: String) -> Observable<[Album]> {
    return Observable.create { observer in
      let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? keyword
      let url = "https://api.spotify.com/v1/search?q=\(encodedKeyword)&type=album&market=JP"

      let req = Just.get(url, headers: Authentication.shared.requestHeader) { r in
        if r.ok {
          if let json = r.json,
             let albums: [Album] = try? decodeArray(json, rootKeyPath: ["albums", "items"]) {
            observer.onNext(albums)
            observer.onCompleted()
          } else {
            observer.onError(APIError.parseError)
          }
        } else {
          observer.onError(APIError.requestError)
        }
      }
      return Disposables.create {
        req.cancel()
      }
    }
  }

  static func fetch(by artist: Artist) -> Observable<[Album]> {
    return Observable.create { observer in
      let url = "\(artist.url)/albums?album_type=album,single&market=JP"
      let req = Just.get(url, headers: Authentication.shared.requestHeader) { r in
        if r.ok {
          if let json = r.json,
             let albums: [Album] = try? decodeArray(json, rootKeyPath: "items") {
            observer.onNext(albums)
            observer.onCompleted()
          } else {
            observer.onError(APIError.parseError)
          }
        } else {
          observer.onError(APIError.requestError)
        }
      }
      return Disposables.create {
        req.cancel()
      }
    }
  }

}
