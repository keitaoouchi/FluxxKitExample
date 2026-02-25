import FluxxKit

struct SearchState: StateType {
    var albums: [Album] = []
    var phase: Phase = .idle

    enum Phase: Sendable {
        case idle
        case searching
        case loaded
        case empty
        case failed
    }
}

enum SearchAction: ActionType {
    case search(keyword: String)
    case loaded([Album])
    case failed
    case reset
}

let searchReducer = LocalReducer<SearchState, SearchAction> { state, action in
    switch action {
    case .search(let keyword):
        var s = state
        s.phase = .searching
        return (s, .run { dispatch in
            do {
                let albums = try await SpotifyAPI.searchAlbums(
                    keyword: keyword,
                    authentication: Authentication()
                )
                await dispatch(.loaded(albums))
            } catch {
                await dispatch(.failed)
            }
        })
    case .loaded(let albums):
        var s = state
        s.albums = albums
        s.phase = albums.isEmpty ? .empty : .loaded
        return (s, .none)
    case .failed:
        var s = state
        s.phase = .failed
        return (s, .none)
    case .reset:
        return (SearchState(), .none)
    }
}
