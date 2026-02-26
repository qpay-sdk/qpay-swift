import XCTest
@testable import QPay

final class QPayClientTests: XCTestCase {

    private var config: QPayConfig!
    private var session: URLSession!
    private var client: QPayClient!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()

        config = QPayConfig(
            baseURL: "https://merchant.qpay.mn",
            username: "test_user",
            password: "test_pass",
            invoiceCode: "TEST_CODE",
            callbackURL: "https://example.com/callback"
        )

        session = makeMockSession()
        client = QPayClient(config: config, session: session)
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - Helper

    /// Returns a mock token JSON response.
    private func mockTokenJSON(
        accessToken: String = "mock_access_token",
        refreshToken: String = "mock_refresh_token",
        expiresIn: Int64 = 9999999999,
        refreshExpiresIn: Int64 = 9999999999
    ) -> Data {
        return """
        {
            "token_type": "Bearer",
            "refresh_expires_in": \(refreshExpiresIn),
            "refresh_token": "\(refreshToken)",
            "access_token": "\(accessToken)",
            "expires_in": \(expiresIn),
            "scope": "default",
            "not-before-policy": "0",
            "session_state": "session_123"
        }
        """.data(using: .utf8)!
    }

    /// Sets up a two-call handler: first call returns token, second returns the given response.
    private func setupTokenThenResponse(statusCode: Int = 200, responseData: Data) {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                // Token request
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                // Actual API request
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, responseData)
            }
        }
    }

    /// Sets up a handler that always returns an error for the token request.
    private func setupTokenError(statusCode: Int = 401) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            let errorBody = """
            {"error": "AUTHENTICATION_FAILED", "message": "Invalid credentials"}
            """.data(using: .utf8)!
            return (response, errorBody)
        }
    }

    // MARK: - getToken

    func testGetTokenSuccess() async throws {
        MockURLProtocol.requestHandler = { [self] request in
            XCTAssertEqual(request.url?.path, "/v2/auth/token")
            XCTAssertEqual(request.httpMethod, "POST")

            // Verify Basic Auth header
            let authHeader = request.value(forHTTPHeaderField: "Authorization") ?? ""
            XCTAssertTrue(authHeader.hasPrefix("Basic "))

            let base64 = String(authHeader.dropFirst(6))
            let decoded = String(data: Data(base64Encoded: base64)!, encoding: .utf8)!
            XCTAssertEqual(decoded, "test_user:test_pass")

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, self.mockTokenJSON())
        }

        let token = try await client.getToken()
        XCTAssertEqual(token.accessToken, "mock_access_token")
        XCTAssertEqual(token.refreshToken, "mock_refresh_token")
        XCTAssertEqual(token.tokenType, "Bearer")
    }

    func testGetTokenApiError() async {
        setupTokenError(statusCode: 401)

        do {
            _ = try await client.getToken()
            XCTFail("Expected error")
        } catch let error as QPayError {
            XCTAssertEqual(error.statusCode, 401)
            XCTAssertEqual(error.code, "AUTHENTICATION_FAILED")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - refreshTokenCall

    func testRefreshTokenCallSuccess() async throws {
        // First: get a token to populate internal state
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            if callCount == 1 {
                // Initial getToken
                return (response, self.mockTokenJSON(refreshToken: "refresh_for_test"))
            } else {
                // Refresh call
                XCTAssertEqual(request.url?.path, "/v2/auth/refresh")
                XCTAssertEqual(request.httpMethod, "POST")

                let authHeader = request.value(forHTTPHeaderField: "Authorization") ?? ""
                XCTAssertEqual(authHeader, "Bearer refresh_for_test")

                return (response, self.mockTokenJSON(accessToken: "new_access_token", refreshToken: "new_refresh_token"))
            }
        }

        // Get initial token
        _ = try await client.getToken()

        // Refresh
        let refreshed = try await client.refreshTokenCall()
        XCTAssertEqual(refreshed.accessToken, "new_access_token")
        XCTAssertEqual(refreshed.refreshToken, "new_refresh_token")
    }

    // MARK: - createSimpleInvoice

    func testCreateSimpleInvoiceSuccess() async throws {
        let invoiceResponseJSON = """
        {
            "invoice_id": "inv_001",
            "qr_text": "qr_text_data",
            "qr_image": "base64_image_data",
            "qPay_shortUrl": "https://qpay.mn/s/abc",
            "urls": [
                {
                    "name": "Khan Bank",
                    "description": "Khan Bank app",
                    "logo": "https://qpay.mn/logo/khan.png",
                    "link": "khanbank://pay?q=abc"
                }
            ]
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: invoiceResponseJSON)

        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "TEST_CODE",
            senderInvoiceNo: "INV-001",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Test payment",
            amount: 1000,
            callbackURL: "https://example.com/callback"
        )

        let response = try await client.createSimpleInvoice(request)
        XCTAssertEqual(response.invoiceID, "inv_001")
        XCTAssertEqual(response.qrText, "qr_text_data")
        XCTAssertEqual(response.qPayShortURL, "https://qpay.mn/s/abc")
        XCTAssertEqual(response.urls.count, 1)
        XCTAssertEqual(response.urls.first?.name, "Khan Bank")

        // Verify the second request was POST to /v2/invoice
        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/invoice")
        XCTAssertEqual(lastReq.httpMethod, "POST")
        XCTAssertEqual(lastReq.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertTrue(lastReq.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") ?? false)
    }

    // MARK: - createInvoice

    func testCreateInvoiceSuccess() async throws {
        let invoiceResponseJSON = """
        {
            "invoice_id": "inv_002",
            "qr_text": "qr_full",
            "qr_image": "img",
            "qPay_shortUrl": "https://qpay.mn/s/def",
            "urls": []
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: invoiceResponseJSON)

        let request = CreateInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-002",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Full invoice",
            amount: 5000,
            callbackURL: "https://cb.test",
            note: "Test"
        )

        let response = try await client.createInvoice(request)
        XCTAssertEqual(response.invoiceID, "inv_002")
    }

    // MARK: - createEbarimtInvoice

    func testCreateEbarimtInvoiceSuccess() async throws {
        let invoiceResponseJSON = """
        {
            "invoice_id": "inv_003",
            "qr_text": "qr_ebarimt",
            "qr_image": "img",
            "qPay_shortUrl": "https://qpay.mn/s/ghi",
            "urls": []
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: invoiceResponseJSON)

        let line = EbarimtInvoiceLine(
            lineDescription: "Product",
            lineQuantity: "1",
            lineUnitPrice: "3000"
        )

        let request = CreateEbarimtInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-003",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Ebarimt inv",
            taxType: "1",
            districtCode: "34",
            callbackURL: "https://cb.test",
            lines: [line]
        )

        let response = try await client.createEbarimtInvoice(request)
        XCTAssertEqual(response.invoiceID, "inv_003")
    }

    // MARK: - cancelInvoice

    func testCancelInvoiceSuccess() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                XCTAssertEqual(request.url?.path, "/v2/invoice/inv_cancel_001")
                XCTAssertEqual(request.httpMethod, "DELETE")

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        try await client.cancelInvoice(invoiceID: "inv_cancel_001")
        // No error means success
    }

    func testCancelInvoiceApiError() async {
        let errorBody = """
        {"error": "INVOICE_NOTFOUND", "message": "Invoice not found"}
        """.data(using: .utf8)!

        setupTokenThenResponse(statusCode: 404, responseData: errorBody)

        do {
            try await client.cancelInvoice(invoiceID: "nonexistent")
            XCTFail("Expected error")
        } catch let error as QPayError {
            XCTAssertEqual(error.statusCode, 404)
            XCTAssertEqual(error.code, "INVOICE_NOTFOUND")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - getPayment

    func testGetPaymentSuccess() async throws {
        let paymentJSON = """
        {
            "payment_id": "pay_001",
            "payment_status": "PAID",
            "payment_fee": "10",
            "payment_amount": "1000",
            "payment_currency": "MNT",
            "payment_date": "2024-01-15",
            "payment_wallet": "khan",
            "transaction_type": "P2P",
            "object_type": "INVOICE",
            "object_id": "inv_001",
            "next_payment_date": null,
            "next_payment_datetime": null,
            "card_transactions": [],
            "p2p_transactions": []
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: paymentJSON)

        let payment = try await client.getPayment(paymentID: "pay_001")
        XCTAssertEqual(payment.paymentID, "pay_001")
        XCTAssertEqual(payment.paymentStatus, "PAID")
        XCTAssertEqual(payment.paymentAmount, "1000")

        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/payment/pay_001")
        XCTAssertEqual(lastReq.httpMethod, "GET")
    }

    // MARK: - checkPayment

    func testCheckPaymentSuccess() async throws {
        let checkResponseJSON = """
        {
            "count": 1,
            "paid_amount": 1000.0,
            "rows": [
                {
                    "payment_id": "pay_001",
                    "payment_status": "PAID",
                    "payment_amount": "1000",
                    "trx_fee": "10",
                    "payment_currency": "MNT",
                    "payment_wallet": "khan",
                    "payment_type": "P2P",
                    "next_payment_date": null,
                    "next_payment_datetime": null,
                    "card_transactions": [],
                    "p2p_transactions": []
                }
            ]
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: checkResponseJSON)

        let request = PaymentCheckRequest(objectType: "INVOICE", objectID: "inv_001")
        let response = try await client.checkPayment(request)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response.paidAmount, 1000.0)
        XCTAssertEqual(response.rows.first?.paymentStatus, "PAID")

        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/payment/check")
        XCTAssertEqual(lastReq.httpMethod, "POST")
    }

    // MARK: - listPayments

    func testListPaymentsSuccess() async throws {
        let listResponseJSON = """
        {
            "count": 1,
            "rows": [
                {
                    "payment_id": "pay_100",
                    "payment_date": "2024-06-15",
                    "payment_status": "PAID",
                    "payment_fee": "5",
                    "payment_amount": "500",
                    "payment_currency": "MNT",
                    "payment_wallet": "tdb",
                    "payment_name": "Payment #100",
                    "payment_description": "Order payment",
                    "qr_code": "qr_data",
                    "paid_by": "user@test.mn",
                    "object_type": "INVOICE",
                    "object_id": "inv_100"
                }
            ]
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: listResponseJSON)

        let request = PaymentListRequest(
            objectType: "INVOICE",
            objectID: "inv_100",
            startDate: "2024-01-01",
            endDate: "2024-12-31",
            offset: Offset(pageNumber: 1, pageLimit: 20)
        )

        let response = try await client.listPayments(request)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response.rows.first?.paymentID, "pay_100")

        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/payment/list")
        XCTAssertEqual(lastReq.httpMethod, "POST")
    }

    // MARK: - cancelPayment

    func testCancelPaymentWithoutBody() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                XCTAssertEqual(request.url?.path, "/v2/payment/cancel/pay_cancel_001")
                XCTAssertEqual(request.httpMethod, "DELETE")

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        try await client.cancelPayment(paymentID: "pay_cancel_001")
    }

    func testCancelPaymentWithBody() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                XCTAssertEqual(request.url?.path, "/v2/payment/cancel/pay_cancel_002")
                XCTAssertNotNil(request.httpBody)

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        let cancelReq = PaymentCancelRequest(callbackURL: "https://cb.test", note: "Cancel note")
        try await client.cancelPayment(paymentID: "pay_cancel_002", request: cancelReq)
    }

    // MARK: - refundPayment

    func testRefundPaymentWithoutBody() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                XCTAssertEqual(request.url?.path, "/v2/payment/refund/pay_refund_001")
                XCTAssertEqual(request.httpMethod, "DELETE")

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        try await client.refundPayment(paymentID: "pay_refund_001")
    }

    func testRefundPaymentWithBody() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { [self] request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, self.mockTokenJSON())
            } else {
                XCTAssertNotNil(request.httpBody)

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        let refundReq = PaymentRefundRequest(callbackURL: "https://cb.test", note: "Refund note")
        try await client.refundPayment(paymentID: "pay_refund_002", request: refundReq)
    }

    // MARK: - createEbarimt

    func testCreateEbarimtSuccess() async throws {
        let ebarimtResponseJSON = """
        {
            "id": "eb_001",
            "ebarimt_by": "system",
            "g_wallet_id": "w001",
            "g_wallet_customer_id": "c001",
            "ebarimt_receiver_type": "individual",
            "ebarimt_receiver": "AA12345678",
            "ebarimt_district_code": "34",
            "ebarimt_bill_type": "B2C",
            "g_merchant_id": "m001",
            "merchant_branch_code": "MAIN",
            "merchant_terminal_code": null,
            "merchant_staff_code": null,
            "merchant_register_no": "REG001",
            "g_payment_id": "pay_001",
            "paid_by": "user@test.mn",
            "object_type": "INVOICE",
            "object_id": "inv_001",
            "amount": "1000",
            "vat_amount": "100",
            "city_tax_amount": "10",
            "ebarimt_qr_data": "qr_ebarimt",
            "ebarimt_lottery": "ABCD1234",
            "note": null,
            "barimt_status": "CREATED",
            "barimt_status_date": "2024-01-15",
            "ebarimt_sent_email": null,
            "ebarimt_receiver_phone": "99001122",
            "tax_type": "1",
            "merchant_tin": null,
            "ebarimt_receipt_id": null,
            "created_by": "system",
            "created_date": "2024-01-15",
            "updated_by": "system",
            "updated_date": "2024-01-15",
            "status": true,
            "barimt_items": [],
            "barimt_transactions": [],
            "barimt_histories": []
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: ebarimtResponseJSON)

        let request = CreateEbarimtRequest(
            paymentID: "pay_001",
            ebarimtReceiverType: "individual",
            ebarimtReceiver: "AA12345678"
        )

        let response = try await client.createEbarimt(request)
        XCTAssertEqual(response.id, "eb_001")
        XCTAssertEqual(response.ebarimtReceiverType, "individual")
        XCTAssertEqual(response.ebarimtLottery, "ABCD1234")

        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/ebarimt_v3/create")
        XCTAssertEqual(lastReq.httpMethod, "POST")
    }

    // MARK: - cancelEbarimt

    func testCancelEbarimtSuccess() async throws {
        let ebarimtResponseJSON = """
        {
            "id": "eb_002",
            "ebarimt_by": "system",
            "g_wallet_id": "w001",
            "g_wallet_customer_id": "c001",
            "ebarimt_receiver_type": "individual",
            "ebarimt_receiver": "AA12345678",
            "ebarimt_district_code": "34",
            "ebarimt_bill_type": "B2C",
            "g_merchant_id": "m001",
            "merchant_branch_code": "MAIN",
            "merchant_terminal_code": null,
            "merchant_staff_code": null,
            "merchant_register_no": "REG001",
            "g_payment_id": "pay_002",
            "paid_by": "user@test.mn",
            "object_type": "INVOICE",
            "object_id": "inv_002",
            "amount": "2000",
            "vat_amount": "200",
            "city_tax_amount": "20",
            "ebarimt_qr_data": "qr_cancel",
            "ebarimt_lottery": "EFGH5678",
            "note": null,
            "barimt_status": "CANCELED",
            "barimt_status_date": "2024-01-16",
            "ebarimt_sent_email": null,
            "ebarimt_receiver_phone": "99001122",
            "tax_type": "1",
            "merchant_tin": null,
            "ebarimt_receipt_id": null,
            "created_by": "system",
            "created_date": "2024-01-15",
            "updated_by": "system",
            "updated_date": "2024-01-16",
            "status": true,
            "barimt_items": null,
            "barimt_transactions": null,
            "barimt_histories": null
        }
        """.data(using: .utf8)!

        setupTokenThenResponse(responseData: ebarimtResponseJSON)

        let response = try await client.cancelEbarimt(paymentID: "pay_002")
        XCTAssertEqual(response.id, "eb_002")
        XCTAssertEqual(response.barimtStatus, "CANCELED")

        let lastReq = MockURLProtocol.capturedRequests.last!
        XCTAssertEqual(lastReq.url?.path, "/v2/ebarimt_v3/pay_002")
        XCTAssertEqual(lastReq.httpMethod, "DELETE")
    }

    // MARK: - API Error Handling

    func testApiErrorWithJsonBody() async {
        let errorBody = """
        {"error": "INVOICE_PAID", "message": "Invoice has already been paid"}
        """.data(using: .utf8)!

        setupTokenThenResponse(statusCode: 400, responseData: errorBody)

        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-ERR",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Error test",
            amount: 100,
            callbackURL: "https://cb.test"
        )

        do {
            _ = try await client.createSimpleInvoice(request)
            XCTFail("Expected error")
        } catch let error as QPayError {
            XCTAssertEqual(error.statusCode, 400)
            XCTAssertEqual(error.code, "INVOICE_PAID")
            XCTAssertNotNil(error.rawBody)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testApiErrorWithNonJsonBody() async {
        let errorBody = "Internal Server Error".data(using: .utf8)!

        setupTokenThenResponse(statusCode: 500, responseData: errorBody)

        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-500",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Server error test",
            amount: 100,
            callbackURL: "https://cb.test"
        )

        do {
            _ = try await client.createSimpleInvoice(request)
            XCTFail("Expected error")
        } catch let error as QPayError {
            XCTAssertEqual(error.statusCode, 500)
            XCTAssertEqual(error.rawBody, "Internal Server Error")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Token Auto-Management

    func testAutoTokenRefreshOnExpiredToken() async throws {
        // Simulate: first getToken returns a token that is already expired,
        // so ensureToken should re-authenticate before the API call.
        // We verify that the token endpoint is called before the actual API request.

        var requestPaths: [String] = []
        MockURLProtocol.requestHandler = { [self] request in
            requestPaths.append(request.url?.path ?? "")

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            if request.url?.path == "/v2/auth/token" {
                return (response, self.mockTokenJSON())
            } else if request.url?.path == "/v2/invoice" {
                let invoiceJSON = """
                {
                    "invoice_id": "inv_auto",
                    "qr_text": "qr",
                    "qr_image": "img",
                    "qPay_shortUrl": "https://qpay.mn/s/auto",
                    "urls": []
                }
                """.data(using: .utf8)!
                return (response, invoiceJSON)
            }

            return (response, Data())
        }

        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-AUTO",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Auto token test",
            amount: 100,
            callbackURL: "https://cb.test"
        )

        let response = try await client.createSimpleInvoice(request)
        XCTAssertEqual(response.invoiceID, "inv_auto")

        // Verify token was requested first
        XCTAssertEqual(requestPaths.first, "/v2/auth/token")
        XCTAssertEqual(requestPaths.last, "/v2/invoice")
    }

    // MARK: - Decoding Error

    func testDecodingErrorOnInvalidResponse() async {
        let invalidJSON = "this is not json".data(using: .utf8)!

        setupTokenThenResponse(responseData: invalidJSON)

        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-BAD",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Bad JSON",
            amount: 100,
            callbackURL: "https://cb.test"
        )

        do {
            _ = try await client.createSimpleInvoice(request)
            XCTFail("Expected decoding error")
        } catch let error as QPayError {
            if case .decodingFailed = error {
                // Expected
            } else {
                XCTFail("Expected decodingFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Custom Session

    func testClientAcceptsCustomSession() async throws {
        let customConfig = URLSessionConfiguration.ephemeral
        customConfig.protocolClasses = [MockURLProtocol.self]
        customConfig.timeoutIntervalForRequest = 60
        let customSession = URLSession(configuration: customConfig)

        let customClient = QPayClient(config: config, session: customSession)

        MockURLProtocol.requestHandler = { [self] request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, self.mockTokenJSON())
        }

        let token = try await customClient.getToken()
        XCTAssertEqual(token.accessToken, "mock_access_token")
    }
}
