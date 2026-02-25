import Foundation
import Observation

@Observable
@MainActor
final class Authentication {
    var accessToken: String?
    var expiresIn: TimeInterval?

    var isAuthenticated: Bool {
        guard let token = accessToken, !token.isEmpty,
              let expiresIn else { return false }
        return Date(timeIntervalSince1970: expiresIn) > Date()
    }

    var requestHeader: [String: String] {
        ["Authorization": "Bearer \(accessToken ?? "")"]
    }

    init() {
        self.accessToken = KeychainHelper.get(forKey: "accessToken")
        if let expiresStr = KeychainHelper.get(forKey: "expiresIn") {
            self.expiresIn = TimeInterval(expiresStr)
        }
    }

    func save(accessToken: String, expiresIn: TimeInterval) {
        let expiresSince1970 = Date().timeIntervalSince1970 + expiresIn
        self.accessToken = accessToken
        self.expiresIn = expiresSince1970
        KeychainHelper.set(accessToken, forKey: "accessToken")
        KeychainHelper.set(String(expiresSince1970), forKey: "expiresIn")
    }

    func invalidate() {
        accessToken = nil
        expiresIn = nil
        KeychainHelper.delete(forKey: "accessToken")
        KeychainHelper.delete(forKey: "expiresIn")
    }
}
