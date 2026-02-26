import XCTest
@testable import QPay

final class QPayConfigTests: XCTestCase {

    // MARK: - Init

    func testInitSetsAllProperties() {
        let config = QPayConfig(
            baseURL: "https://merchant.qpay.mn",
            username: "test_user",
            password: "test_pass",
            invoiceCode: "INV_CODE",
            callbackURL: "https://example.com/callback"
        )

        XCTAssertEqual(config.baseURL, "https://merchant.qpay.mn")
        XCTAssertEqual(config.username, "test_user")
        XCTAssertEqual(config.password, "test_pass")
        XCTAssertEqual(config.invoiceCode, "INV_CODE")
        XCTAssertEqual(config.callbackURL, "https://example.com/callback")
    }

    // MARK: - fromEnvironment

    func testFromEnvironmentThrowsWhenBaseURLMissing() {
        // Clear all QPay env vars to ensure clean state
        unsetAllQPayEnv()

        setenv("QPAY_USERNAME", "user", 1)
        setenv("QPAY_PASSWORD", "pass", 1)
        setenv("QPAY_INVOICE_CODE", "code", 1)
        setenv("QPAY_CALLBACK_URL", "https://cb.test", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError, got \(type(of: error))")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_BASE_URL")
            } else {
                XCTFail("Expected configMissing, got \(qpayError)")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentThrowsWhenUsernameMissing() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "https://merchant.qpay.mn", 1)
        setenv("QPAY_PASSWORD", "pass", 1)
        setenv("QPAY_INVOICE_CODE", "code", 1)
        setenv("QPAY_CALLBACK_URL", "https://cb.test", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_USERNAME")
            } else {
                XCTFail("Expected configMissing for QPAY_USERNAME")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentThrowsWhenPasswordMissing() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "https://merchant.qpay.mn", 1)
        setenv("QPAY_USERNAME", "user", 1)
        setenv("QPAY_INVOICE_CODE", "code", 1)
        setenv("QPAY_CALLBACK_URL", "https://cb.test", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_PASSWORD")
            } else {
                XCTFail("Expected configMissing for QPAY_PASSWORD")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentThrowsWhenInvoiceCodeMissing() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "https://merchant.qpay.mn", 1)
        setenv("QPAY_USERNAME", "user", 1)
        setenv("QPAY_PASSWORD", "pass", 1)
        setenv("QPAY_CALLBACK_URL", "https://cb.test", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_INVOICE_CODE")
            } else {
                XCTFail("Expected configMissing for QPAY_INVOICE_CODE")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentThrowsWhenCallbackURLMissing() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "https://merchant.qpay.mn", 1)
        setenv("QPAY_USERNAME", "user", 1)
        setenv("QPAY_PASSWORD", "pass", 1)
        setenv("QPAY_INVOICE_CODE", "code", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_CALLBACK_URL")
            } else {
                XCTFail("Expected configMissing for QPAY_CALLBACK_URL")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentThrowsForEmptyValue() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "", 1)
        setenv("QPAY_USERNAME", "user", 1)
        setenv("QPAY_PASSWORD", "pass", 1)
        setenv("QPAY_INVOICE_CODE", "code", 1)
        setenv("QPAY_CALLBACK_URL", "https://cb.test", 1)

        XCTAssertThrowsError(try QPayConfig.fromEnvironment()) { error in
            guard let qpayError = error as? QPayError else {
                XCTFail("Expected QPayError")
                return
            }
            if case .configMissing(let variable) = qpayError {
                XCTAssertEqual(variable, "QPAY_BASE_URL")
            } else {
                XCTFail("Expected configMissing for empty QPAY_BASE_URL")
            }
        }

        unsetAllQPayEnv()
    }

    func testFromEnvironmentSucceedsWithAllVars() {
        unsetAllQPayEnv()

        setenv("QPAY_BASE_URL", "https://merchant.qpay.mn", 1)
        setenv("QPAY_USERNAME", "test_user", 1)
        setenv("QPAY_PASSWORD", "test_pass", 1)
        setenv("QPAY_INVOICE_CODE", "TEST_CODE", 1)
        setenv("QPAY_CALLBACK_URL", "https://example.com/cb", 1)

        do {
            let config = try QPayConfig.fromEnvironment()
            XCTAssertEqual(config.baseURL, "https://merchant.qpay.mn")
            XCTAssertEqual(config.username, "test_user")
            XCTAssertEqual(config.password, "test_pass")
            XCTAssertEqual(config.invoiceCode, "TEST_CODE")
            XCTAssertEqual(config.callbackURL, "https://example.com/cb")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        unsetAllQPayEnv()
    }

    // MARK: - Helpers

    private func unsetAllQPayEnv() {
        unsetenv("QPAY_BASE_URL")
        unsetenv("QPAY_USERNAME")
        unsetenv("QPAY_PASSWORD")
        unsetenv("QPAY_INVOICE_CODE")
        unsetenv("QPAY_CALLBACK_URL")
    }
}
