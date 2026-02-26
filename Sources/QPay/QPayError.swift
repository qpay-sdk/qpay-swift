import Foundation

/// Errors returned by the QPay SDK.
public enum QPayError: Error, Sendable {
    /// A required configuration environment variable is missing.
    case configMissing(variable: String)

    /// The QPay API returned an error response.
    case apiError(statusCode: Int, code: String, message: String, rawBody: String)

    /// Failed to build the HTTP request.
    case requestFailed(String)

    /// Failed to decode the response body.
    case decodingFailed(String)

    /// Failed to encode the request body.
    case encodingFailed(String)

    /// An unexpected error occurred.
    case unexpected(String)
}

extension QPayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configMissing(let variable):
            return "qpay: required environment variable \(variable) is not set"
        case .apiError(let statusCode, let code, let message, _):
            return "qpay: \(code) - \(message) (status \(statusCode))"
        case .requestFailed(let reason):
            return "qpay: request failed - \(reason)"
        case .decodingFailed(let reason):
            return "qpay: failed to decode response - \(reason)"
        case .encodingFailed(let reason):
            return "qpay: failed to encode request - \(reason)"
        case .unexpected(let reason):
            return "qpay: unexpected error - \(reason)"
        }
    }
}

extension QPayError {
    /// Returns the API error code if this is an `.apiError`, otherwise `nil`.
    public var code: String? {
        if case .apiError(_, let code, _, _) = self {
            return code
        }
        return nil
    }

    /// Returns the HTTP status code if this is an `.apiError`, otherwise `nil`.
    public var statusCode: Int? {
        if case .apiError(let statusCode, _, _, _) = self {
            return statusCode
        }
        return nil
    }

    /// Returns the raw response body if this is an `.apiError`, otherwise `nil`.
    public var rawBody: String? {
        if case .apiError(_, _, _, let rawBody) = self {
            return rawBody
        }
        return nil
    }
}
