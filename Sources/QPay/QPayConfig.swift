import Foundation

/// Configuration for the QPay client.
public struct QPayConfig: Sendable {
    /// QPay API base URL (e.g. "https://merchant.qpay.mn").
    public let baseURL: String

    /// QPay merchant username.
    public let username: String

    /// QPay merchant password.
    public let password: String

    /// Default invoice code.
    public let invoiceCode: String

    /// Payment callback URL.
    public let callbackURL: String

    public init(
        baseURL: String,
        username: String,
        password: String,
        invoiceCode: String,
        callbackURL: String
    ) {
        self.baseURL = baseURL
        self.username = username
        self.password = password
        self.invoiceCode = invoiceCode
        self.callbackURL = callbackURL
    }

    /// Loads configuration from environment variables.
    ///
    /// Required variables:
    /// - `QPAY_BASE_URL`
    /// - `QPAY_USERNAME`
    /// - `QPAY_PASSWORD`
    /// - `QPAY_INVOICE_CODE`
    /// - `QPAY_CALLBACK_URL`
    ///
    /// - Throws: `QPayError.configMissing` if any required variable is not set.
    public static func fromEnvironment() throws -> QPayConfig {
        let keys = [
            "QPAY_BASE_URL",
            "QPAY_USERNAME",
            "QPAY_PASSWORD",
            "QPAY_INVOICE_CODE",
            "QPAY_CALLBACK_URL",
        ]

        var values: [String: String] = [:]
        for key in keys {
            guard let value = ProcessInfo.processInfo.environment[key], !value.isEmpty else {
                throw QPayError.configMissing(variable: key)
            }
            values[key] = value
        }

        return QPayConfig(
            baseURL: values["QPAY_BASE_URL"]!,
            username: values["QPAY_USERNAME"]!,
            password: values["QPAY_PASSWORD"]!,
            invoiceCode: values["QPAY_INVOICE_CODE"]!,
            callbackURL: values["QPAY_CALLBACK_URL"]!
        )
    }
}
