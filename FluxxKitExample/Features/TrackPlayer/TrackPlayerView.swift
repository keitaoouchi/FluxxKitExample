import SwiftUI
import FluxxKit

struct TrackPlayerView: View {
    @Environment(Store<TrackPlayerState, TrackPlayerAction>.self) private var store
    @State private var audioPlayer = AudioPlayer()

    var body: some View {
        if let track = store.state.currentTrack {
            HStack(spacing: 12) {
                if let album = track.album,
                   let imageUrl = album.images.first?.url,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    store.dispatch(.toggleCurrent)
                } label: {
                    Image(systemName: store.state.playerPhase == .playing
                          ? "pause.fill" : "play.fill")
                        .font(.title3)
                }

                Button {
                    store.dispatch(.stop)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 56)
            .background(.ultraThinMaterial)
            .onChange(of: store.state.playerPhase) { _, newPhase in
                handlePhaseChange(newPhase, track: track)
            }
            .onChange(of: store.state.currentTrack?.id) { oldId, newId in
                if oldId != newId, let track = store.state.currentTrack,
                   store.state.playerPhase == .playing {
                    playTrack(track)
                }
            }
            .onAppear {
                if store.state.playerPhase == .playing {
                    playTrack(track)
                }
            }
            .onDisappear {
                audioPlayer.stop()
            }
        }
    }

    private func playTrack(_ track: Track) {
        let store = store
        audioPlayer.play(track: track) {
            await store.dispatch(.playbackEnded)
        }
    }

    private func handlePhaseChange(_ phase: TrackPlayerState.PlayerPhase, track: Track) {
        switch phase {
        case .playing:
            playTrack(track)
        case .paused:
            audioPlayer.pause()
        case .ready:
            audioPlayer.stop()
        }
    }
}
