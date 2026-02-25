import SwiftUI
import FluxxKit

struct AlbumDetailView: View {
    let album: Album
    @State private var store = Store(initialState: AlbumDetailState(), reducer: albumDetailReducer)
    @Environment(Store<TrackPlayerState, TrackPlayerAction>.self) private var trackPlayerStore

    var body: some View {
        List {
            Section {
                albumHeader
            }
            .listRowSeparator(.hidden)

            Section {
                switch store.state.phase {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                case .loaded:
                    ForEach(store.state.tracks) { track in
                        TrackRow(
                            track: track,
                            isPlaying: trackPlayerStore.state.currentTrack?.id == track.id
                                && trackPlayerStore.state.playerPhase == .playing
                        ) {
                            trackPlayerStore.dispatch(.toggle(track))
                        }
                    }
                case .empty:
                    Text("No tracks found")
                        .foregroundStyle(.secondary)
                case .failed:
                    LoadingStateView(phase: .failed) {
                        store.dispatch(.fetchTracks(albumId: album.id))
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.dispatch(.fetchTracks(albumId: album.id))
        }
    }

    private var albumHeader: some View {
        VStack(spacing: 12) {
            if let imageUrl = album.images.first?.url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text(album.title)
                .font(.title2)
                .fontWeight(.bold)

            ForEach(album.artists) { artist in
                NavigationLink(value: artist) {
                    Text(artist.name)
                        .font(.subheadline)
                        .foregroundStyle(Color.spotifyGreen)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
