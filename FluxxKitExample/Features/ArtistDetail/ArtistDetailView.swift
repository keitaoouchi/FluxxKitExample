import SwiftUI
import FluxxKit

struct ArtistDetailView: View {
    let artist: Artist
    @State private var store: Store<ArtistDetailState, ArtistDetailAction>

    init(artist: Artist, store: Store<ArtistDetailState, ArtistDetailAction> = Store(initialState: ArtistDetailState(), reducer: artistDetailReducer)) {
        self.artist = artist
        _store = State(initialValue: store)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                artistHeader

                if !store.state.albums.isEmpty {
                    AlbumGridView(title: "Albums", albums: store.state.albums)
                }

                if !store.state.singles.isEmpty {
                    AlbumGridView(title: "Singles", albums: store.state.singles)
                }

                if !store.state.relatedArtists.isEmpty {
                    RelatedArtistGridView(artists: store.state.relatedArtists)
                }
            }
            .padding(.bottom, 80)
        }
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.dispatch(.fetchAll(artist: artist))
        }
    }

    @ViewBuilder
    private var artistHeader: some View {
        VStack(spacing: 12) {
            if let imageUrl = store.state.images.first?.url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            } else if store.state.imagesPhase == .loading {
                ProgressView()
                    .frame(width: 200, height: 200)
            }

            Text(artist.name)
                .font(.title)
                .fontWeight(.bold)

            if let spotifyUrl = artist.externalUrls?.spotify,
               let url = URL(string: spotifyUrl) {
                Link(destination: url) {
                    Label("Open in Spotify", systemImage: "arrow.up.right.circle")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}
