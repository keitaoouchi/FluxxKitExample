import FluxxKit
import RxSwift

struct AlbumDetailViewModel: StateType {

  let requestState = Variable<RequestState>(.requesting)

  enum RequestState {
    case requesting
    case empty
    case failed(error: Error)
    case done(tracks: [Track])
  }

}

// MARK: - FLUX

extension AlbumDetailViewModel {

  enum Action: FluxxKit.ActionType {
    case request(album: Album)
    case transition(state: RequestState)
  }

  class ThunkMiddleware: MiddlewareType {

    func before(dispatch action: FluxxKit.ActionType, to store: StoreType) {
    }

    func after(dispatch action: FluxxKit.ActionType, to store: StoreType) {
      guard case let Action.request(album) = action else {
        return
      }

      store.dispatch(action: Action.transition(state: .requesting))

      _ = Track.getAll(from: album).subscribe { result in
        switch result {
        case .next(let tracks):
          if tracks.isEmpty {
            store.dispatch(action: Action.transition(state: .empty))
          } else {
            store.dispatch(action: Action.transition(state: .done(tracks: tracks)))
          }
        case .error(let error):
          store.dispatch(action: Action.transition(state: .failed(error: error)))
        default:
          break
        }
      }
    }
  }

  class StoreReducer: Reducer<AlbumDetailViewModel, Action> {

    override func reduce(action: AlbumDetailViewModel.Action, to state: AlbumDetailViewModel) {
      switch action {

      case .transition(let newState):
        state.requestState.value = newState

      default:
        break
      }
    }
  }

}
