import FluxxKit
import RxSwift

struct TrackPlayerViewModel: StateType {

  var player = TrackPlayer()

  var trackStream: Variable<Track?> {
    return player.trackStream
  }

  var playerState: Variable<TrackPlayer.State> {
    return player.state
  }

  let hiddenState = Variable<HiddenState>(.hidden)

  enum HiddenState {
    case hidden
    case showing
  }

}

// MARK: - FLUX

extension TrackPlayerViewModel {

  enum Action: FluxxKit.ActionType {
    case stop
    case pause
    case play(track: Track)
    case toggle(track: Track)
    case toggleCurrentTrack

    case show
    case hide
  }

  class StoreReducer: Reducer<TrackPlayerViewModel, Action> {

    override func reduce(state: TrackPlayerViewModel, action: TrackPlayerViewModel.Action) {
      switch action {

      case .show:
        state.hiddenState.value = .showing

      case .hide:
        state.hiddenState.value = .hidden

      case .stop:
        state.player.stop()

      case .pause:
        state.player.pause()

      case .play(let track):
        state.player.play(track: track)

      case .toggle(let newTrack):
        if newTrack.id == state.trackStream.value?.id {
          reduce(state: state, action: .toggleCurrentTrack)
        } else {
          reduce(state: state, action: .play(track: newTrack))
        }

      case .toggleCurrentTrack:
        switch state.playerState.value {
        case .playing:
          state.player.pause()
        case .paused:
          state.player.replay()
        default:
          break
        }
      }
    }

  }

}
