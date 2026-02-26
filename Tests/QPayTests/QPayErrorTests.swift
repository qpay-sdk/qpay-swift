import XCTest
@testable import QPay

final class QPayErrorTests: XCTestCase {

    // MARK: - Error Cases

    func testConfigMissingErrorDescription() {
        let error = QPayError.configMissing(variable: "QPAY_BASE_URL")
        XCTAssertEqual(
            error.errorDescription,
            "qpay: required environment variable QPAY_BASE_URL is not set"
        )
    }

    func testApiErrorErrorDescription() {
        let error = QPayError.apiError(
            statusCode: 401,
            code: "AUTHENTICATION_FAILED",
            message: "Invalid credentials",
            rawBody: "{\"error\":\"AUTHENTICATION_FAILED\"}"
        )
        XCTAssertEqual(
            error.errorDescription,
            "qpay: AUTHENTICATION_FAILED - Invalid credentials (status 401)"
        )
    }

    func testRequestFailedErrorDescription() {
        let error = QPayError.requestFailed("invalid URL")
        XCTAssertEqual(error.errorDescription, "qpay: request failed - invalid URL")
    }

    func testDecodingFailedErrorDescription() {
        let error = QPayError.decodingFailed("missing key 'id'")
        XCTAssertEqual(error.errorDescription, "qpay: failed to decode response - missing key 'id'")
    }

    func testEncodingFailedErrorDescription() {
        let error = QPayError.encodingFailed("invalid value")
        XCTAssertEqual(error.errorDescription, "qpay: failed to encode request - invalid value")
    }

    func testUnexpectedErrorDescription() {
        let error = QPayError.unexpected("something went wrong")
        XCTAssertEqual(error.errorDescription, "qpay: unexpected error - something went wrong")
    }

    // MARK: - Convenience Properties

    func testCodePropertyForApiError() {
        let error = QPayError.apiError(
            statusCode: 404,
            code: "INVOICE_NOTFOUND",
            message: "Not found",
            rawBody: ""
        )
        XCTAssertEqual(error.code, "INVOICE_NOTFOUND")
    }

    func testCodePropertyForNonApiError() {
        let error = QPayError.requestFailed("timeout")
        XCTAssertNil(error.code)
    }

    func testStatusCodePropertyForApiError() {
        let error = QPayError.apiError(
            statusCode: 403,
            code: "PERMISSION_DENIED",
            message: "Forbidden",
            rawBody: ""
        )
        XCTAssertEqual(error.statusCode, 403)
    }

    func testStatusCodePropertyForNonApiError() {
        let error = QPayError.decodingFailed("bad json")
        XCTAssertNil(error.statusCode)
    }

    func testRawBodyPropertyForApiError() {
        let rawBody = "{\"error\":\"INVOICE_PAID\",\"message\":\"Already paid\"}"
        let error = QPayError.apiError(
            statusCode: 400,
            code: "INVOICE_PAID",
            message: "Already paid",
            rawBody: rawBody
        )
        XCTAssertEqual(error.rawBody, rawBody)
    }

    func testRawBodyPropertyForNonApiError() {
        let error = QPayError.configMissing(variable: "QPAY_USERNAME")
        XCTAssertNil(error.rawBody)
    }

    // MARK: - Error Codes

    func testErrorCodeConstants() {
        XCTAssertEqual(QPayErrorCode.authenticationFailed, "AUTHENTICATION_FAILED")
        XCTAssertEqual(QPayErrorCode.invoiceNotFound, "INVOICE_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.invoicePaid, "INVOICE_PAID")
        XCTAssertEqual(QPayErrorCode.invoiceAlreadyCanceled, "INVOICE_ALREADY_CANCELED")
        XCTAssertEqual(QPayErrorCode.paymentNotFound, "PAYMENT_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.paymentAlreadyCanceled, "PAYMENT_ALREADY_CANCELED")
        XCTAssertEqual(QPayErrorCode.paymentNotPaid, "PAYMENT_NOT_PAID")
        XCTAssertEqual(QPayErrorCode.permissionDenied, "PERMISSION_DENIED")
        XCTAssertEqual(QPayErrorCode.invalidAmount, "INVALID_AMOUNT")
        XCTAssertEqual(QPayErrorCode.noCredentials, "NO_CREDENDIALS")
        XCTAssertEqual(QPayErrorCode.merchantNotFound, "MERCHANT_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.merchantInactive, "MERCHANT_INACTIVE")
        XCTAssertEqual(QPayErrorCode.clientNotFound, "CLIENT_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.invoiceCodeInvalid, "INVOICE_CODE_INVALID")
        XCTAssertEqual(QPayErrorCode.invoiceLineRequired, "INVOICE_LINE_REQUIRED")
        XCTAssertEqual(QPayErrorCode.ebarimtNotRegistered, "EBARIMT_NOT_REGISTERED")
        XCTAssertEqual(QPayErrorCode.ebarimtCancelNotSupported, "EBARIMT_CANCEL_NOTSUPPERDED")
        XCTAssertEqual(QPayErrorCode.ebarimtQRCodeInvalid, "EBARIMT_QR_CODE_INVALID")
        XCTAssertEqual(QPayErrorCode.transactionRequired, "TRANSACTION_REQUIRED")
        XCTAssertEqual(QPayErrorCode.transactionNotApproved, "TRANSACTION_NOT_APPROVED")
        XCTAssertEqual(QPayErrorCode.maxAmountError, "MAX_AMOUNT_ERR")
        XCTAssertEqual(QPayErrorCode.minAmountError, "MIN_AMOUNT_ERR")
        XCTAssertEqual(QPayErrorCode.objectDataError, "OBJECT_DATA_ERROR")
        XCTAssertEqual(QPayErrorCode.invalidObjectType, "INVALID_OBJECT_TYPE")
        XCTAssertEqual(QPayErrorCode.customerNotFound, "CUSTOMER_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.customerDuplicate, "CUSTOMER_DUPLICATE")
        XCTAssertEqual(QPayErrorCode.customerRegisterInvalid, "CUSTOMER_REGISTER_INVALID")
        XCTAssertEqual(QPayErrorCode.bankAccountNotFound, "BANK_ACCOUNT_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.accountBankDuplicated, "ACCOUNT_BANK_DUPLICATED")
        XCTAssertEqual(QPayErrorCode.accountSelectionInvalid, "ACCOUNT_SELECTION_INVALID")
        XCTAssertEqual(QPayErrorCode.senderBranchDataRequired, "SENDER_BRANCH_DATA_REQUIRED")
        XCTAssertEqual(QPayErrorCode.taxLineRequired, "TAX_LINE_REQUIRED")
        XCTAssertEqual(QPayErrorCode.taxProductCodeRequired, "TAX_PRODUCT_CODE_REQUIRED")
        XCTAssertEqual(QPayErrorCode.qrCodeNotFound, "QRCODE_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.qrCodeUsed, "QRCODE_USED")
        XCTAssertEqual(QPayErrorCode.qrAccountNotFound, "QRACCOUNT_NOTFOUND")
        XCTAssertEqual(QPayErrorCode.qrAccountInactive, "QRACCOUNT_INACTIVE")
    }

    // MARK: - Conforms to Error protocol

    func testErrorConformance() {
        let error: Error = QPayError.requestFailed("test")
        XCTAssertNotNil(error as? QPayError)
    }

    func testLocalizedErrorConformance() {
        let error: LocalizedError = QPayError.unexpected("test")
        XCTAssertNotNil(error.errorDescription)
    }
}
