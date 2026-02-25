import SwiftUI
import FluxxKit

struct ContentView: View {
    @Environment(Authentication.self) private var authentication
    @Environment(Store<TrackPlayerState, TrackPlayerAction>.self) private var trackPlayerStore

    var body: some View {
        ZStack(alignment: .bottom) {
            if authentication.isAuthenticated {
                SearchView()
            } else {
                OAuthView()
            }

            if trackPlayerStore.state.visibility == .showing {
                TrackPlayerView()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: trackPlayerStore.state.visibility == .showing)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if !authentication.isAuthenticated {
                authentication.invalidate()
            }
        }
    }
}
