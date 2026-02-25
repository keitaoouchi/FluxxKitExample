import SwiftUI
import FluxxKit

struct SearchView: View {
    @State private var store = Store(initialState: SearchState(), reducer: searchReducer)
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                switch store.state.phase {
                case .idle:
                    ContentUnavailableView(
                        "Search Albums",
                        systemImage: "magnifyingglass",
                        description: Text("Search for albums on Spotify")
                    )
                case .searching:
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded:
                    List(store.state.albums) { album in
                        NavigationLink(value: album) {
                            AlbumCardView(album: album)
                        }
                    }
                    .listStyle(.plain)
                case .empty:
                    ContentUnavailableView.search(text: searchText)
                case .failed:
                    LoadingStateView(phase: .failed) {
                        store.dispatch(.search(keyword: searchText))
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Album name")
            .onSubmit(of: .search) {
                guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                store.dispatch(.search(keyword: searchText))
            }
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
            .navigationDestination(for: Artist.self) { artist in
                ArtistDetailView(artist: artist)
            }
        }
    }
}
