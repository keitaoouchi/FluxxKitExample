import FluxxKit
import RxSwift

struct ArtistDetailViewModel: StateType {

  let imagesRequestState = Variable<ImagesRequestState>(.requesting)
  let albumsRequestState = Variable<AlbumsRequestState>(.requesting)
  let singlesRequestState = Variable<SinglesRequestState>(.requesting)
  let relatedArtistsRequestState = Variable<RelatedArtistsRequestState>(.requesting)

  enum ImagesRequestState {
    case requesting
    case empty
    case failed(error: Error)
    case done(images: [Image])
  }

  enum AlbumsRequestState {
    case requesting
    case empty
    case failed(error: Error)
    case done(albums: [Album])
  }

  enum SinglesRequestState {
    case requesting
    case empty
    case failed(error: Error)
    case done(singles: [Album])
  }

  enum RelatedArtistsRequestState {
    case requesting
    case empty
    case failed(error: Error)
    case done(artists: [Artist])
  }

}

// MARK: - FLUX

extension ArtistDetailViewModel {

  enum TransitionType {
    case image(state: ImagesRequestState)
    case albums(state: AlbumsRequestState)
    case singles(state: SinglesRequestState)
    case relatedArtists(state: RelatedArtistsRequestState)
  }

  enum Action: FluxxKit.ActionType {
    case requestImages(artist: Artist)
    case requestAlbumsAndSingles(artist: Artist)
    case requestRelatedArtists(artist: Artist)
    case transition(type: TransitionType)
  }

  class ThunkMiddleware: MiddlewareType {

    func before(dispatch action: FluxxKit.ActionType, to store: StoreType) {
    }

    func after(dispatch action: FluxxKit.ActionType, to store: StoreType) {
      guard let action = action as? Action else { return }

      switch action {
      case .requestImages(let artist):

        store.dispatch(
            action: Action.transition(type: .image(state: .requesting))
        )

        _ = artist.getImages().subscribe(
            onNext: { images in
              if images.isEmpty {
                store.dispatch(
                    action: Action.transition(type: .image(state: .empty))
                )
              } else {
                store.dispatch(
                    action: Action.transition(type: .image(state: .done(images: images)))
                )
              }
            },
            onError: { error in
              store.dispatch(
                  action: Action.transition(type: .image(state: .failed(error: error)))
              )
            }
        )

      case .requestAlbumsAndSingles(let artist):

        store.dispatch(
            action: Action.transition(type: .albums(state: .requesting))
        )

        store.dispatch(
            action: Action.transition(type: .singles(state: .requesting))
        )

        _ = Album.fetch(by: artist).subscribe(
            onNext: { releases in
              var albums = [Album]()
              var singles = [Album]()
              releases.forEach { release in
                if release.type == "album" {
                  albums.append(release)
                } else if release.type == "single" {
                  singles.append(release)
                }
              }

              if albums.isEmpty {
                store.dispatch(
                    action: Action.transition(type: .albums(state: .empty))
                )
              } else {
                store.dispatch(
                    action: Action.transition(type: .albums(state: .done(albums: albums)))
                )
              }

              if singles.isEmpty {
                store.dispatch(
                    action: Action.transition(type: .singles(state: .empty))
                )
              } else {
                store.dispatch(
                    action: Action.transition(type: .singles(state: .done(singles: singles)))
                )
              }
            },
            onError: { error in
              store.dispatch(
                  action: Action.transition(type: .albums(state: .failed(error: error)))
              )
              store.dispatch(
                  action: Action.transition(type: .singles(state: .failed(error: error)))
              )
            }
        )

      case .requestRelatedArtists(let artist):

        store.dispatch(
            action: Action.transition(type: .relatedArtists(state: .requesting))
        )

        _ = Artist.fetchRelatedArtists(for: artist).subscribe(
            onNext: { artists in
              if artists.isEmpty {
                store.dispatch(
                    action: Action.transition(type: .relatedArtists(state: .empty))
                )
              } else {
                store.dispatch(
                    action: Action.transition(type: .relatedArtists(state: .done(artists: artists)))
                )
              }
            },
            onError: { error in
              store.dispatch(
                  action: Action.transition(type: .relatedArtists(state: .failed(error: error)))
              )
            }
        )

      default:
        break
      }
    }

  }

  class StoreReducer: Reducer<ArtistDetailViewModel, Action> {
    override func reduce(action: ArtistDetailViewModel.Action, to state: ArtistDetailViewModel) {

      switch action {

      case .transition(let type):

        switch type {
        case .image(let newState):
          state.imagesRequestState.value = newState

        case .albums(let newState):
          state.albumsRequestState.value = newState

        case .singles(let newState):
          state.singlesRequestState.value = newState

        case .relatedArtists(let newState):
          state.relatedArtistsRequestState.value = newState
        }

      default:
        break
      }
    }

  }

}
