import FluxxKit

struct TrackPlayerState: StateType {
    var currentTrack: Track?
    var playerPhase: PlayerPhase = .ready
    var visibility: Visibility = .hidden

    enum PlayerPhase: Sendable {
        case ready
        case playing
        case paused
    }

    enum Visibility: Sendable {
        case hidden
        case showing
    }
}

enum TrackPlayerAction: ActionType {
    case play(Track)
    case pause
    case resume
    case stop
    case toggle(Track)
    case toggleCurrent
    case show
    case hide
    case playbackEnded
}

let trackPlayerReducer = Reducer<TrackPlayerState, TrackPlayerAction> { state, action in
    switch action {
    case .play(let track):
        var s = state
        s.currentTrack = track
        s.playerPhase = .playing
        s.visibility = .showing
        return (s, .none)
    case .pause:
        var s = state
        s.playerPhase = .paused
        return (s, .none)
    case .resume:
        var s = state
        s.playerPhase = .playing
        return (s, .none)
    case .stop:
        var s = state
        s.playerPhase = .ready
        s.visibility = .hidden
        s.currentTrack = nil
        return (s, .none)
    case .toggle(let track):
        if track.id == state.currentTrack?.id {
            switch state.playerPhase {
            case .playing:
                var s = state
                s.playerPhase = .paused
                return (s, .none)
            case .paused:
                var s = state
                s.playerPhase = .playing
                return (s, .none)
            case .ready:
                var s = state
                s.currentTrack = track
                s.playerPhase = .playing
                s.visibility = .showing
                return (s, .none)
            }
        } else {
            var s = state
            s.currentTrack = track
            s.playerPhase = .playing
            s.visibility = .showing
            return (s, .none)
        }
    case .toggleCurrent:
        switch state.playerPhase {
        case .playing:
            var s = state
            s.playerPhase = .paused
            return (s, .none)
        case .paused:
            var s = state
            s.playerPhase = .playing
            return (s, .none)
        case .ready:
            return (state, .none)
        }
    case .show:
        var s = state
        s.visibility = .showing
        return (s, .none)
    case .hide:
        var s = state
        s.visibility = .hidden
        return (s, .none)
    case .playbackEnded:
        var s = state
        s.playerPhase = .ready
        return (s, .none)
    }
}
