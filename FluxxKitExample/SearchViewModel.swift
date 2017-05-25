import FluxxKit
import RxSwift

struct SearchViewModel {

  let searchState = Variable<SearchState>(.initial)

  enum SearchState {
    case initial
    case searching
    case empty
    case failed(error: Error)
    case done(albums: [Album])
  }

}

// MARK: - FLUX

extension SearchViewModel: StateType {

  enum Action: FluxxKit.ActionType {
    case search(keyword: String)
    case transition(state: SearchState)
    case cancel
  }

  class ThunkMiddleware: MiddlewareType {

    func after(dispatch action: FluxxKit.ActionType, to store: StoreType) {
    }

    func before(dispatch action: FluxxKit.ActionType, to store: StoreType) {
      guard case let Action.search(keyword) = action else {
        return
      }

      store.dispatch(action: Action.transition(state: .searching))
      _ = Album.search(keyword: keyword).subscribe { result in
        switch result {
        case .next(let albums):
          if albums.isEmpty {
            store.dispatch(action: Action.transition(state: .empty))
          } else {
            store.dispatch(action: Action.transition(state: .done(albums: albums)))
          }
        case .error(let error):
          store.dispatch(action: Action.transition(state: .failed(error: error)))
        default:
          break
        }
      }
    }
  }

  class StoreReducer: Reducer<SearchViewModel, Action> {

    override func reduce(state: SearchViewModel, action: SearchViewModel.Action) {
      switch action {
      case .transition(let newState):
        state.searchState.value = newState
      case .cancel:
        state.searchState.value = .initial
      default:
        break
      }
    }
  }

}
