import Foundation

/// Thread-safe QPay V2 API client with automatic token management.
///
/// Uses Swift actor isolation to ensure safe concurrent access to token state.
/// All API methods use async/await and URLSession for HTTP communication.
///
/// Usage:
/// ```swift
/// let config = QPayConfig(
///     baseURL: "https://merchant.qpay.mn",
///     username: "YOUR_USERNAME",
///     password: "YOUR_PASSWORD",
///     invoiceCode: "YOUR_CODE",
///     callbackURL: "https://yoursite.com/callback"
/// )
/// let client = QPayClient(config: config)
///
/// let invoice = try await client.createSimpleInvoice(
///     CreateSimpleInvoiceRequest(
///         invoiceCode: config.invoiceCode,
///         senderInvoiceNo: "INV-001",
///         invoiceReceiverCode: "terminal",
///         invoiceDescription: "Test payment",
///         amount: 100,
///         callbackURL: config.callbackURL
///     )
/// )
/// ```
public actor QPayClient {

    private let config: QPayConfig
    private let session: URLSession

    private var accessToken: String = ""
    private var refreshToken: String = ""
    private var expiresAt: Int64 = 0
    private var refreshExpiresAt: Int64 = 0

    private static let tokenBufferSeconds: Int64 = 30

    /// Creates a new QPay client with the given configuration.
    ///
    /// - Parameters:
    ///   - config: QPay configuration with credentials and URLs.
    ///   - session: Optional custom URLSession. Defaults to a session with 30-second timeout.
    public init(config: QPayConfig, session: URLSession? = nil) {
        self.config = config
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            self.session = URLSession(configuration: configuration)
        }
    }

    // MARK: - Auth

    /// Authenticates with QPay using Basic Auth and returns a new token pair.
    /// The tokens are stored internally for subsequent requests.
    ///
    /// - Returns: The token response.
    @discardableResult
    public func getToken() async throws -> TokenResponse {
        let token = try await getTokenRequest()
        storeToken(token)
        return token
    }

    /// Uses the current refresh token to obtain a new access token.
    /// The new tokens are stored internally for subsequent requests.
    ///
    /// - Returns: The token response.
    @discardableResult
    public func refreshTokenCall() async throws -> TokenResponse {
        let currentRefreshToken = refreshToken
        let token = try await doRefreshTokenHTTP(refreshToken: currentRefreshToken)
        storeToken(token)
        return token
    }

    // MARK: - Invoice

    /// Creates a detailed invoice with full options.
    /// POST /v2/invoice
    ///
    /// - Parameter request: The full invoice creation request.
    /// - Returns: The invoice response with QR code and deeplinks.
    public func createInvoice(_ request: CreateInvoiceRequest) async throws -> InvoiceResponse {
        return try await doRequest(method: "POST", path: "/v2/invoice", body: request)
    }

    /// Creates a simple invoice with minimal fields.
    /// POST /v2/invoice
    ///
    /// - Parameter request: The simple invoice creation request.
    /// - Returns: The invoice response with QR code and deeplinks.
    public func createSimpleInvoice(_ request: CreateSimpleInvoiceRequest) async throws -> InvoiceResponse {
        return try await doRequest(method: "POST", path: "/v2/invoice", body: request)
    }

    /// Creates an invoice with ebarimt (tax) information.
    /// POST /v2/invoice
    ///
    /// - Parameter request: The ebarimt invoice creation request.
    /// - Returns: The invoice response with QR code and deeplinks.
    public func createEbarimtInvoice(_ request: CreateEbarimtInvoiceRequest) async throws -> InvoiceResponse {
        return try await doRequest(method: "POST", path: "/v2/invoice", body: request)
    }

    /// Cancels an existing invoice by ID.
    /// DELETE /v2/invoice/{id}
    ///
    /// - Parameter invoiceID: The invoice ID to cancel.
    public func cancelInvoice(invoiceID: String) async throws {
        try await doRequestNoResponse(method: "DELETE", path: "/v2/invoice/\(invoiceID)")
    }

    // MARK: - Payment

    /// Retrieves payment details by payment ID.
    /// GET /v2/payment/{id}
    ///
    /// - Parameter paymentID: The payment ID.
    /// - Returns: Payment detail information.
    public func getPayment(paymentID: String) async throws -> PaymentDetail {
        return try await doRequest(method: "GET", path: "/v2/payment/\(paymentID)")
    }

    /// Checks if a payment has been made for an invoice.
    /// POST /v2/payment/check
    ///
    /// - Parameter request: The payment check request.
    /// - Returns: The payment check response.
    public func checkPayment(_ request: PaymentCheckRequest) async throws -> PaymentCheckResponse {
        return try await doRequest(method: "POST", path: "/v2/payment/check", body: request)
    }

    /// Returns a list of payments matching the given criteria.
    /// POST /v2/payment/list
    ///
    /// - Parameter request: The payment list request with filtering options.
    /// - Returns: The payment list response.
    public func listPayments(_ request: PaymentListRequest) async throws -> PaymentListResponse {
        return try await doRequest(method: "POST", path: "/v2/payment/list", body: request)
    }

    /// Cancels a payment (card transactions only).
    /// DELETE /v2/payment/cancel/{id}
    ///
    /// - Parameters:
    ///   - paymentID: The payment ID to cancel.
    ///   - request: Optional cancellation request with callback URL and note.
    public func cancelPayment(paymentID: String, request: PaymentCancelRequest? = nil) async throws {
        if let request = request {
            try await doRequestNoResponse(method: "DELETE", path: "/v2/payment/cancel/\(paymentID)", body: request)
        } else {
            try await doRequestNoResponse(method: "DELETE", path: "/v2/payment/cancel/\(paymentID)")
        }
    }

    /// Refunds a payment (card transactions only).
    /// DELETE /v2/payment/refund/{id}
    ///
    /// - Parameters:
    ///   - paymentID: The payment ID to refund.
    ///   - request: Optional refund request with callback URL and note.
    public func refundPayment(paymentID: String, request: PaymentRefundRequest? = nil) async throws {
        if let request = request {
            try await doRequestNoResponse(method: "DELETE", path: "/v2/payment/refund/\(paymentID)", body: request)
        } else {
            try await doRequestNoResponse(method: "DELETE", path: "/v2/payment/refund/\(paymentID)")
        }
    }

    // MARK: - Ebarimt

    /// Creates an ebarimt (electronic tax receipt) for a payment.
    /// POST /v2/ebarimt_v3/create
    ///
    /// - Parameter request: The ebarimt creation request.
    /// - Returns: The ebarimt response.
    public func createEbarimt(_ request: CreateEbarimtRequest) async throws -> EbarimtResponse {
        return try await doRequest(method: "POST", path: "/v2/ebarimt_v3/create", body: request)
    }

    /// Cancels an ebarimt by payment ID.
    /// DELETE /v2/ebarimt_v3/{id}
    ///
    /// - Parameter paymentID: The payment ID whose ebarimt to cancel.
    /// - Returns: The ebarimt response.
    @discardableResult
    public func cancelEbarimt(paymentID: String) async throws -> EbarimtResponse {
        return try await doRequest(method: "DELETE", path: "/v2/ebarimt_v3/\(paymentID)")
    }

    // MARK: - Token Management (Private)

    private func ensureToken() async throws {
        let now = Int64(Date().timeIntervalSince1970)

        // Access token still valid
        if !accessToken.isEmpty && now < expiresAt - Self.tokenBufferSeconds {
            return
        }

        // Try refresh if possible
        let canRefresh = !refreshToken.isEmpty && now < refreshExpiresAt - Self.tokenBufferSeconds
        if canRefresh {
            do {
                let token = try await doRefreshTokenHTTP(refreshToken: refreshToken)
                storeToken(token)
                return
            } catch {
                // Refresh failed, fall through to full auth
            }
        }

        // Both expired or no tokens, get new token
        let token = try await getTokenRequest()
        storeToken(token)
    }

    private func storeToken(_ token: TokenResponse) {
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        expiresAt = token.expiresIn
        refreshExpiresAt = token.refreshExpiresIn
    }

    private func getTokenRequest() async throws -> TokenResponse {
        return try await doBasicAuthRequest(method: "POST", path: "/v2/auth/token")
    }

    private func doRefreshTokenHTTP(refreshToken: String) async throws -> TokenResponse {
        guard let url = URL(string: config.baseURL + "/v2/auth/refresh") else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch {
            throw QPayError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: - HTTP Helpers (Private)

    private func doRequest<T: Encodable, R: Decodable>(method: String, path: String, body: T) async throws -> R {
        try await ensureToken()

        guard let url = URL(string: config.baseURL + path) else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw QPayError.encodingFailed(error.localizedDescription)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw QPayError.decodingFailed(error.localizedDescription)
        }
    }

    private func doRequest<R: Decodable>(method: String, path: String) async throws -> R {
        try await ensureToken()

        guard let url = URL(string: config.baseURL + path) else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw QPayError.decodingFailed(error.localizedDescription)
        }
    }

    private func doRequestNoResponse(method: String, path: String) async throws {
        try await ensureToken()

        guard let url = URL(string: config.baseURL + path) else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    private func doRequestNoResponse<T: Encodable>(method: String, path: String, body: T) async throws {
        try await ensureToken()

        guard let url = URL(string: config.baseURL + path) else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw QPayError.encodingFailed(error.localizedDescription)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    private func doBasicAuthRequest<R: Decodable>(method: String, path: String) async throws -> R {
        guard let url = URL(string: config.baseURL + path) else {
            throw QPayError.requestFailed("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let credentials = "\(config.username):\(config.password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw QPayError.requestFailed("failed to encode credentials")
        }
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QPayError.requestFailed("invalid response type")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw QPayError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: - Error Parsing

    private func parseAPIError(statusCode: Int, data: Data) -> QPayError {
        let rawBody = String(data: data, encoding: .utf8) ?? ""

        struct APIErrorBody: Decodable {
            let error: String?
            let message: String?
        }

        let body = try? JSONDecoder().decode(APIErrorBody.self, from: data)
        let code = body?.error ?? HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let message = body?.message ?? rawBody

        return QPayError.apiError(
            statusCode: statusCode,
            code: code,
            message: message,
            rawBody: rawBody
        )
    }
}
