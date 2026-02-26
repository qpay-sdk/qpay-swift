import Foundation

/// Token response from QPay authentication endpoints.
public struct TokenResponse: Codable, Sendable {
    public let tokenType: String
    public let refreshExpiresIn: Int64
    public let refreshToken: String
    public let accessToken: String
    public let expiresIn: Int64
    public let scope: String
    public let notBeforePolicy: String
    public let sessionState: String

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case refreshExpiresIn = "refresh_expires_in"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case scope
        case notBeforePolicy = "not-before-policy"
        case sessionState = "session_state"
    }
}
