import SwiftUI
import AuthenticationServices
import CryptoKit

struct OAuthView: View {
    @Environment(Authentication.self) private var authentication
    @State private var showWebAuth = false

    private let clientId = "57e837fb225048c286c07d06bd236631"
    private let redirectUri = "fluxxkitexample://callback"

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

        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        context.coordinator.codeVerifier = codeVerifier

        let state = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let encodedRedirect = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirectUri
        let urlString = "https://accounts.spotify.com/authorize?"
            + "client_id=\(clientId)&"
            + "response_type=code&"
            + "redirect_uri=\(encodedRedirect)&"
            + "code_challenge_method=S256&"
            + "code_challenge=\(codeChallenge)&"
            + "state=\(state)"
        guard let url = URL(string: urlString) else { return vc }

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "fluxxkitexample"
        ) { callbackURL, error in
            guard error == nil, let callbackURL else { return }
            processCallback(url: callbackURL, codeVerifier: codeVerifier)
        }
        session.prefersEphemeralWebBrowserSession = true
        context.coordinator.session = session
        context.coordinator.presentingVC = vc

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            session.presentationContextProvider = context.coordinator
            session.start()
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func processCallback(url: URL, codeVerifier: String) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        Task { @MainActor in
            await exchangeCodeForToken(code: code, codeVerifier: codeVerifier)
        }
    }

    private func exchangeCodeForToken(code: String, codeVerifier: String) async {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(redirectUri)",
            "client_id=\(clientId)",
            "code_verifier=\(codeVerifier)"
        ].joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            authentication.save(accessToken: response.accessToken, expiresIn: response.expiresIn)
        } catch {
            // Token exchange failed
        }
    }

    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    final class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
        var session: ASWebAuthenticationSession?
        weak var presentingVC: UIViewController?
        var codeVerifier: String = ""

        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            presentingVC?.view.window ?? ASPresentationAnchor()
        }
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Double

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
