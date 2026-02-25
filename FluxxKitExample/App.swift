import SwiftUI
import FluxxKit

@main
struct FluxxKitExampleApp: App {
    @State private var authentication = Authentication()
    @State private var trackPlayerStore = Store(
        initialState: TrackPlayerState(),
        reducer: trackPlayerReducer
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authentication)
                .environment(trackPlayerStore)
        }
    }
}
