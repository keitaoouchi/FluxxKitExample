import SwiftUI

struct LoadingStateView: View {
    let phase: Phase
    var onRetry: (() -> Void)?

    enum Phase {
        case loading
        case empty
        case failed
    }

    var body: some View {
        switch phase {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            ContentUnavailableView(
                "No Results",
                systemImage: "tray",
                description: Text("Nothing found.")
            )
        case .failed:
            ContentUnavailableView {
                Label("Error", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Something went wrong.")
            } actions: {
                if let onRetry {
                    Button("Retry", action: onRetry)
                        .buttonStyle(.bordered)
                }
            }
        }
    }
}
