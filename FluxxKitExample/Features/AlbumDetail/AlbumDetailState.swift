import FluxxKit

struct AlbumDetailState: StateType {
    var tracks: [Track] = []
    var phase: Phase = .loading

    enum Phase: Sendable {
        case loading
        case loaded
        case empty
        case failed
    }
}

enum AlbumDetailAction: ActionType {
    case fetchTracks(albumId: String)
    case loaded([Track])
    case failed
}

let albumDetailReducer = Reducer<AlbumDetailState, AlbumDetailAction> { state, action in
    switch action {
    case .fetchTracks(let albumId):
        var s = state
        s.phase = .loading
        return (s, .run { dispatch in
            do {
                let tracks = try await SpotifyAPI.fetchTracks(
                    albumId: albumId,
                    authentication: Authentication()
                )
                await dispatch(.loaded(tracks))
            } catch {
                await dispatch(.failed)
            }
        })
    case .loaded(let tracks):
        var s = state
        s.tracks = tracks
        s.phase = tracks.isEmpty ? .empty : .loaded
        return (s, .none)
    case .failed:
        var s = state
        s.phase = .failed
        return (s, .none)
    }
}
