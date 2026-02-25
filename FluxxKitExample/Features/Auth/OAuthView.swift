import SwiftUI
import AuthenticationServices

struct OAuthView: View {
    @Environment(Authentication.self) private var authentication
    @State private var showWebAuth = false

    private let clientId = "57e837fb225048c286c07d06bd236631"
    private let redirectUri = "https://github.com/keitaoouchi/FluxxKitExample"

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(Color.spotifyGreen)

            Text("FluxxKit Example")
                .font(.title)
                .fontWeight(.bold)

            Text("Spotify Client")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showWebAuth = true
            } label: {
                Label("Sign in with Spotify", systemImage: "person.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.spotifyGreen)
            .padding(.horizontal, 40)

            Spacer()
        }
        .sheet(isPresented: $showWebAuth) {
            SpotifyAuthSheet(
                clientId: clientId,
                redirectUri: redirectUri,
                authentication: authentication
            )
        }
    }
}

private struct SpotifyAuthSheet: UIViewControllerRepresentable {
    let clientId: String
    let redirectUri: String
    let authentication: Authentication
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground

        let state = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let encodedRedirect = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirectUri
        let urlString = "https://accounts.spotify.com/authorize?"
            + "client_id=\(clientId)&"
            + "response_type=token&"
            + "redirect_uri=\(encodedRedirect)&"
            + "state=\(state)"
        guard let url = URL(string: urlString) else { return vc }

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: nil
        ) { callbackURL, error in
            guard error == nil, let callbackURL else { return }
            processCallback(url: callbackURL)
        }
        session.prefersEphemeralWebBrowserSession = true
        context.coordinator.session = session
        context.coordinator.presentingVC = vc

        // Start after brief delay to let VC present
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            session.presentationContextProvider = context.coordinator
            session.start()
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func processCallback(url: URL) {
        // The redirect URL for implicit grant returns params in fragment (#)
        // but ASWebAuthenticationSession may deliver them in query (?) or fragment
        let components = url.absoluteString.components(separatedBy: "#")
        guard components.count > 1 else { return }
        var items: [String: String] = [:]
        components[1]
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .forEach { parts in
                if let key = parts.first, let value = parts.last {
                    items[key] = value
                }
            }
        if let token = items["access_token"],
           let expiresStr = items["expires_in"],
           let expiresIn = Double(expiresStr) {
            Task { @MainActor in
                authentication.save(accessToken: token, expiresIn: expiresIn)
            }
        }
    }

    final class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
        var session: ASWebAuthenticationSession?
        weak var presentingVC: UIViewController?

        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            presentingVC?.view.window ?? ASPresentationAnchor()
        }
    }
}
