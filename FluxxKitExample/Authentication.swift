import RxSwift
import KeychainAccess

final class Authentication {

  static let shared = Authentication()

  lazy var valid: Variable<Bool> = {
    return Variable<Bool>(self.isValid())
  }()

  // TimeInterval since 1970
  var expiresIn: TimeInterval? {
    get {
      let keychain = Keychain(service: "FluxxKitExample")
      do {
        if let encoded = try keychain.get("expiresIn"), let decoded = TimeInterval(encoded) {
          return decoded
        }
        return nil
      } catch {
        return nil
      }
    }

    set {
      let keychain = Keychain(service: "FluxxKitExample")
      if let newValue = newValue {
        let encoded = String(newValue)
        try? keychain.set(encoded, key: "expiresIn")
      } else {
        try? keychain.remove("expiresIn")
      }
      self.valid.value = isValid()
    }
  }

  var accessToken: String? {

    get {
      let keychain = Keychain(service: "FluxxKitExample")
      do {
        return try keychain.get("accessToken")
      } catch {
        return nil
      }
    }

    set {
      let keychain = Keychain(service: "FluxxKitExample")
      if let newValue = newValue {
        try? keychain.set(newValue, key: "accessToken")
      } else {
        try? keychain.remove("accessToken")
      }
      self.valid.value = isValid()
    }

  }

  var requestHeader: [String: String] {
    return [
      "Authorization": "Bearer \(accessToken ?? "")"
    ]
  }

  func invalidate() {
    accessToken = nil
    expiresIn = nil
  }

  func isValid() -> Bool {
    if let token = accessToken, let expiresIn = expiresIn {
      let expireDate = Date(timeIntervalSince1970: expiresIn)
      let now = Date()
      return expireDate > now && !token.isEmpty
    }
    return false
  }
}
