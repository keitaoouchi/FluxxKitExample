import Foundation

enum APIError: Error, Sendable {
    case requestError
    case parseError
    case unauthorized
}
