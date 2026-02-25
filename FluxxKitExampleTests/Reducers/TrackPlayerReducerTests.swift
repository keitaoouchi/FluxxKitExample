import Testing
@testable import FluxxKitExample
import FluxxKit

@Suite("TrackPlayer Reducer")
struct TrackPlayerReducerTests {

    private let sampleTrack = Track(
        id: "1", name: "Test Track", trackNumber: 1,
        previewUrl: "https://example.com/preview.mp3",
        durationMs: 30000, album: nil
    )

    private let otherTrack = Track(
        id: "2", name: "Other Track", trackNumber: 2,
        previewUrl: "https://example.com/preview2.mp3",
        durationMs: 30000, album: nil
    )

    @Test func playSetsCurrent() {
        let state = TrackPlayerState()
        let (newState, _) = trackPlayerReducer.reduce(state, .play(sampleTrack))
        #expect(newState.currentTrack?.id == "1")
        #expect(newState.playerPhase == .playing)
        #expect(newState.visibility == .showing)
    }

    @Test func pauseSetsPhase() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        let (newState, _) = trackPlayerReducer.reduce(state, .pause)
        #expect(newState.playerPhase == .paused)
    }

    @Test func resumeSetsPhase() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .paused
        let (newState, _) = trackPlayerReducer.reduce(state, .resume)
        #expect(newState.playerPhase == .playing)
    }

    @Test func stopResetsState() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        state.visibility = .showing
        let (newState, _) = trackPlayerReducer.reduce(state, .stop)
        #expect(newState.playerPhase == .ready)
        #expect(newState.visibility == .hidden)
        #expect(newState.currentTrack == nil)
    }

    @Test func toggleSameTrackWhilePlayingPauses() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        let (newState, _) = trackPlayerReducer.reduce(state, .toggle(sampleTrack))
        #expect(newState.playerPhase == .paused)
    }

    @Test func toggleSameTrackWhilePausedResumes() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .paused
        let (newState, _) = trackPlayerReducer.reduce(state, .toggle(sampleTrack))
        #expect(newState.playerPhase == .playing)
    }

    @Test func toggleDifferentTrackPlays() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        let (newState, _) = trackPlayerReducer.reduce(state, .toggle(otherTrack))
        #expect(newState.currentTrack?.id == "2")
        #expect(newState.playerPhase == .playing)
    }

    @Test func toggleCurrentWhilePlaying() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        let (newState, _) = trackPlayerReducer.reduce(state, .toggleCurrent)
        #expect(newState.playerPhase == .paused)
    }

    @Test func toggleCurrentWhilePaused() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .paused
        let (newState, _) = trackPlayerReducer.reduce(state, .toggleCurrent)
        #expect(newState.playerPhase == .playing)
    }

    @Test func showAndHide() {
        let state = TrackPlayerState()
        let (shown, _) = trackPlayerReducer.reduce(state, .show)
        #expect(shown.visibility == .showing)
        let (hidden, _) = trackPlayerReducer.reduce(shown, .hide)
        #expect(hidden.visibility == .hidden)
    }

    @Test func playbackEnded() {
        var state = TrackPlayerState()
        state.currentTrack = sampleTrack
        state.playerPhase = .playing
        let (newState, _) = trackPlayerReducer.reduce(state, .playbackEnded)
        #expect(newState.playerPhase == .ready)
    }
}
