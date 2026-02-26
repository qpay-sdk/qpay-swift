import XCTest
@testable import QPay

final class ModelTests: XCTestCase {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - TokenResponse

    func testTokenResponseDecoding() throws {
        let json = """
        {
            "token_type": "Bearer",
            "refresh_expires_in": 1800000,
            "refresh_token": "refresh_abc",
            "access_token": "access_xyz",
            "expires_in": 300000,
            "scope": "default",
            "not-before-policy": "0",
            "session_state": "session_123"
        }
        """.data(using: .utf8)!

        let token = try decoder.decode(TokenResponse.self, from: json)
        XCTAssertEqual(token.tokenType, "Bearer")
        XCTAssertEqual(token.refreshExpiresIn, 1800000)
        XCTAssertEqual(token.refreshToken, "refresh_abc")
        XCTAssertEqual(token.accessToken, "access_xyz")
        XCTAssertEqual(token.expiresIn, 300000)
        XCTAssertEqual(token.scope, "default")
        XCTAssertEqual(token.notBeforePolicy, "0")
        XCTAssertEqual(token.sessionState, "session_123")
    }

    func testTokenResponseRoundtrip() throws {
        let token = TokenResponse(
            tokenType: "Bearer",
            refreshExpiresIn: 1800,
            refreshToken: "rt",
            accessToken: "at",
            expiresIn: 300,
            scope: "default",
            notBeforePolicy: "0",
            sessionState: "sess"
        )

        let data = try encoder.encode(token)
        let decoded = try decoder.decode(TokenResponse.self, from: data)

        XCTAssertEqual(decoded.tokenType, token.tokenType)
        XCTAssertEqual(decoded.accessToken, token.accessToken)
        XCTAssertEqual(decoded.refreshToken, token.refreshToken)
        XCTAssertEqual(decoded.expiresIn, token.expiresIn)
        XCTAssertEqual(decoded.refreshExpiresIn, token.refreshExpiresIn)
    }

    // MARK: - CreateSimpleInvoiceRequest

    func testCreateSimpleInvoiceRequestEncoding() throws {
        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "TEST_CODE",
            senderInvoiceNo: "INV-001",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Test payment",
            amount: 1000.50,
            callbackURL: "https://example.com/cb"
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["invoice_code"] as? String, "TEST_CODE")
        XCTAssertEqual(dict["sender_invoice_no"] as? String, "INV-001")
        XCTAssertEqual(dict["invoice_receiver_code"] as? String, "terminal")
        XCTAssertEqual(dict["invoice_description"] as? String, "Test payment")
        XCTAssertEqual(dict["amount"] as? Double, 1000.50)
        XCTAssertEqual(dict["callback_url"] as? String, "https://example.com/cb")
    }

    func testCreateSimpleInvoiceRequestRoundtrip() throws {
        let request = CreateSimpleInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-002",
            invoiceReceiverCode: "term",
            invoiceDescription: "Desc",
            senderBranchCode: "BRANCH",
            amount: 500,
            callbackURL: "https://cb.test"
        )

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(CreateSimpleInvoiceRequest.self, from: data)

        XCTAssertEqual(decoded.invoiceCode, request.invoiceCode)
        XCTAssertEqual(decoded.senderInvoiceNo, request.senderInvoiceNo)
        XCTAssertEqual(decoded.senderBranchCode, "BRANCH")
        XCTAssertEqual(decoded.amount, 500)
    }

    // MARK: - CreateInvoiceRequest

    func testCreateInvoiceRequestWithAllFields() throws {
        let request = CreateInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-003",
            senderBranchCode: "BRANCH",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Full invoice",
            enableExpiry: "true",
            allowPartial: true,
            minimumAmount: 100,
            allowExceed: false,
            maximumAmount: 5000,
            amount: 2500,
            callbackURL: "https://cb.test",
            note: "Test note"
        )

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(CreateInvoiceRequest.self, from: data)

        XCTAssertEqual(decoded.invoiceCode, "CODE")
        XCTAssertEqual(decoded.allowPartial, true)
        XCTAssertEqual(decoded.minimumAmount, 100)
        XCTAssertEqual(decoded.allowExceed, false)
        XCTAssertEqual(decoded.maximumAmount, 5000)
        XCTAssertEqual(decoded.note, "Test note")
    }

    // MARK: - CreateEbarimtInvoiceRequest

    func testCreateEbarimtInvoiceRequestEncoding() throws {
        let line = EbarimtInvoiceLine(
            taxProductCode: "TAX001",
            lineDescription: "Product",
            lineQuantity: "1",
            lineUnitPrice: "1000"
        )

        let request = CreateEbarimtInvoiceRequest(
            invoiceCode: "CODE",
            senderInvoiceNo: "INV-004",
            invoiceReceiverCode: "terminal",
            invoiceDescription: "Ebarimt invoice",
            taxType: "1",
            districtCode: "34",
            callbackURL: "https://cb.test",
            lines: [line]
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["tax_type"] as? String, "1")
        XCTAssertEqual(dict["district_code"] as? String, "34")

        let lines = dict["lines"] as? [[String: Any]]
        XCTAssertEqual(lines?.count, 1)
        XCTAssertEqual(lines?.first?["tax_product_code"] as? String, "TAX001")
    }

    // MARK: - InvoiceResponse

    func testInvoiceResponseDecoding() throws {
        let json = """
        {
            "invoice_id": "inv_123",
            "qr_text": "qr_text_data",
            "qr_image": "base64image",
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

        let response = try decoder.decode(InvoiceResponse.self, from: json)
        XCTAssertEqual(response.invoiceID, "inv_123")
        XCTAssertEqual(response.qrText, "qr_text_data")
        XCTAssertEqual(response.qrImage, "base64image")
        XCTAssertEqual(response.qPayShortURL, "https://qpay.mn/s/abc")
        XCTAssertEqual(response.urls.count, 1)
        XCTAssertEqual(response.urls.first?.name, "Khan Bank")
        XCTAssertEqual(response.urls.first?.link, "khanbank://pay?q=abc")
    }

    // MARK: - PaymentCheckRequest

    func testPaymentCheckRequestEncoding() throws {
        let request = PaymentCheckRequest(
            objectType: "INVOICE",
            objectID: "inv_123",
            offset: Offset(pageNumber: 1, pageLimit: 10)
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["object_type"] as? String, "INVOICE")
        XCTAssertEqual(dict["object_id"] as? String, "inv_123")

        let offset = dict["offset"] as? [String: Any]
        XCTAssertEqual(offset?["page_number"] as? Int, 1)
        XCTAssertEqual(offset?["page_limit"] as? Int, 10)
    }

    // MARK: - PaymentCheckResponse

    func testPaymentCheckResponseDecoding() throws {
        let json = """
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

        let response = try decoder.decode(PaymentCheckResponse.self, from: json)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response.paidAmount, 1000.0)
        XCTAssertEqual(response.rows.count, 1)
        XCTAssertEqual(response.rows.first?.paymentID, "pay_001")
        XCTAssertEqual(response.rows.first?.paymentStatus, "PAID")
    }

    // MARK: - PaymentDetail

    func testPaymentDetailDecoding() throws {
        let json = """
        {
            "payment_id": "pay_002",
            "payment_status": "PAID",
            "payment_fee": "15",
            "payment_amount": "2000",
            "payment_currency": "MNT",
            "payment_date": "2024-01-15",
            "payment_wallet": "golomt",
            "transaction_type": "P2P",
            "object_type": "INVOICE",
            "object_id": "inv_456",
            "next_payment_date": null,
            "next_payment_datetime": null,
            "card_transactions": [],
            "p2p_transactions": [
                {
                    "transaction_bank_code": "15",
                    "account_bank_code": "04",
                    "account_bank_name": "Golomt Bank",
                    "account_number": "1234567890",
                    "status": "SUCCESS",
                    "amount": "2000",
                    "currency": "MNT",
                    "settlement_status": "SETTLED"
                }
            ]
        }
        """.data(using: .utf8)!

        let detail = try decoder.decode(PaymentDetail.self, from: json)
        XCTAssertEqual(detail.paymentID, "pay_002")
        XCTAssertEqual(detail.paymentStatus, "PAID")
        XCTAssertEqual(detail.paymentFee, "15")
        XCTAssertEqual(detail.objectType, "INVOICE")
        XCTAssertEqual(detail.p2pTransactions.count, 1)
        XCTAssertEqual(detail.p2pTransactions.first?.accountBankName, "Golomt Bank")
        XCTAssertEqual(detail.cardTransactions.count, 0)
    }

    // MARK: - PaymentListRequest / Response

    func testPaymentListRequestEncoding() throws {
        let request = PaymentListRequest(
            objectType: "INVOICE",
            objectID: "inv_789",
            startDate: "2024-01-01",
            endDate: "2024-12-31",
            offset: Offset(pageNumber: 1, pageLimit: 20)
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["object_type"] as? String, "INVOICE")
        XCTAssertEqual(dict["start_date"] as? String, "2024-01-01")
        XCTAssertEqual(dict["end_date"] as? String, "2024-12-31")
    }

    func testPaymentListResponseDecoding() throws {
        let json = """
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

        let response = try decoder.decode(PaymentListResponse.self, from: json)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response.rows.first?.paymentID, "pay_100")
        XCTAssertEqual(response.rows.first?.paymentName, "Payment #100")
    }

    // MARK: - PaymentCancelRequest

    func testPaymentCancelRequestEncoding() throws {
        let request = PaymentCancelRequest(
            callbackURL: "https://cb.test/cancel",
            note: "Customer requested"
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["callback_url"] as? String, "https://cb.test/cancel")
        XCTAssertEqual(dict["note"] as? String, "Customer requested")
    }

    func testPaymentCancelRequestWithNilFields() throws {
        let request = PaymentCancelRequest()

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(PaymentCancelRequest.self, from: data)

        XCTAssertNil(decoded.callbackURL)
        XCTAssertNil(decoded.note)
    }

    // MARK: - PaymentRefundRequest

    func testPaymentRefundRequestRoundtrip() throws {
        let request = PaymentRefundRequest(
            callbackURL: "https://cb.test/refund",
            note: "Refund note"
        )

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(PaymentRefundRequest.self, from: data)

        XCTAssertEqual(decoded.callbackURL, "https://cb.test/refund")
        XCTAssertEqual(decoded.note, "Refund note")
    }

    // MARK: - CreateEbarimtRequest

    func testCreateEbarimtRequestEncoding() throws {
        let request = CreateEbarimtRequest(
            paymentID: "pay_001",
            ebarimtReceiverType: "individual",
            ebarimtReceiver: "AA12345678",
            districtCode: "34"
        )

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["payment_id"] as? String, "pay_001")
        XCTAssertEqual(dict["ebarimt_receiver_type"] as? String, "individual")
        XCTAssertEqual(dict["ebarimt_receiver"] as? String, "AA12345678")
        XCTAssertEqual(dict["district_code"] as? String, "34")
    }

    // MARK: - Common Models

    func testAddressRoundtrip() throws {
        let address = Address(
            city: "Ulaanbaatar",
            district: "Sukhbaatar",
            street: "Peace Ave",
            building: "100",
            zipcode: "14200"
        )

        let data = try encoder.encode(address)
        let decoded = try decoder.decode(Address.self, from: data)

        XCTAssertEqual(decoded.city, "Ulaanbaatar")
        XCTAssertEqual(decoded.district, "Sukhbaatar")
        XCTAssertEqual(decoded.street, "Peace Ave")
        XCTAssertEqual(decoded.building, "100")
        XCTAssertEqual(decoded.zipcode, "14200")
        XCTAssertNil(decoded.longitude)
        XCTAssertNil(decoded.latitude)
        XCTAssertNil(decoded.address)
    }

    func testSenderBranchDataRoundtrip() throws {
        let branchData = SenderBranchData(
            register: "REG001",
            name: "Main Branch",
            email: "branch@test.mn",
            phone: "99001122"
        )

        let data = try encoder.encode(branchData)
        let decoded = try decoder.decode(SenderBranchData.self, from: data)

        XCTAssertEqual(decoded.register, "REG001")
        XCTAssertEqual(decoded.name, "Main Branch")
        XCTAssertEqual(decoded.email, "branch@test.mn")
    }

    func testSenderStaffDataRoundtrip() throws {
        let staffData = SenderStaffData(
            name: "John",
            email: "john@test.mn",
            phone: "88001122"
        )

        let data = try encoder.encode(staffData)
        let decoded = try decoder.decode(SenderStaffData.self, from: data)

        XCTAssertEqual(decoded.name, "John")
        XCTAssertEqual(decoded.email, "john@test.mn")
    }

    func testInvoiceReceiverDataRoundtrip() throws {
        let receiverData = InvoiceReceiverData(
            register: "RCV001",
            name: "Receiver",
            email: "recv@test.mn",
            phone: "77001122"
        )

        let data = try encoder.encode(receiverData)
        let decoded = try decoder.decode(InvoiceReceiverData.self, from: data)

        XCTAssertEqual(decoded.register, "RCV001")
        XCTAssertEqual(decoded.name, "Receiver")
    }

    func testAccountDecoding() throws {
        let json = """
        {
            "account_bank_code": "04",
            "account_number": "1234567890",
            "iban_number": "MN041234567890",
            "account_name": "Test Account",
            "account_currency": "MNT",
            "is_default": true
        }
        """.data(using: .utf8)!

        let account = try decoder.decode(Account.self, from: json)
        XCTAssertEqual(account.accountBankCode, "04")
        XCTAssertEqual(account.accountNumber, "1234567890")
        XCTAssertEqual(account.ibanNumber, "MN041234567890")
        XCTAssertEqual(account.accountName, "Test Account")
        XCTAssertEqual(account.accountCurrency, "MNT")
        XCTAssertTrue(account.isDefault)
    }

    func testTransactionRoundtrip() throws {
        let transaction = Transaction(
            description: "Order payment",
            amount: "5000"
        )

        let data = try encoder.encode(transaction)
        let decoded = try decoder.decode(Transaction.self, from: data)

        XCTAssertEqual(decoded.description, "Order payment")
        XCTAssertEqual(decoded.amount, "5000")
        XCTAssertNil(decoded.accounts)
    }

    func testTaxEntryEncoding() throws {
        let entry = TaxEntry(
            taxCode: "VAT",
            description: "Value Added Tax",
            amount: 100.0,
            note: "10%"
        )

        let data = try encoder.encode(entry)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["tax_code"] as? String, "VAT")
        XCTAssertEqual(dict["description"] as? String, "Value Added Tax")
        XCTAssertEqual(dict["amount"] as? Double, 100.0)
    }

    func testInvoiceLineRoundtrip() throws {
        let line = InvoiceLine(
            taxProductCode: "PROD001",
            lineDescription: "Widget",
            lineQuantity: "2",
            lineUnitPrice: "500"
        )

        let data = try encoder.encode(line)
        let decoded = try decoder.decode(InvoiceLine.self, from: data)

        XCTAssertEqual(decoded.taxProductCode, "PROD001")
        XCTAssertEqual(decoded.lineDescription, "Widget")
        XCTAssertEqual(decoded.lineQuantity, "2")
        XCTAssertEqual(decoded.lineUnitPrice, "500")
    }

    func testEbarimtInvoiceLineRoundtrip() throws {
        let line = EbarimtInvoiceLine(
            taxProductCode: "TAX001",
            lineDescription: "Service",
            barcode: "1234567890123",
            lineQuantity: "1",
            lineUnitPrice: "2000",
            classificationCode: "CLS001"
        )

        let data = try encoder.encode(line)
        let decoded = try decoder.decode(EbarimtInvoiceLine.self, from: data)

        XCTAssertEqual(decoded.barcode, "1234567890123")
        XCTAssertEqual(decoded.classificationCode, "CLS001")
        XCTAssertEqual(decoded.lineDescription, "Service")
    }

    func testDeeplinkRoundtrip() throws {
        let deeplink = Deeplink(
            name: "Khan Bank",
            description: "Pay with Khan Bank",
            logo: "https://qpay.mn/logo/khan.png",
            link: "khanbank://pay?q=abc"
        )

        let data = try encoder.encode(deeplink)
        let decoded = try decoder.decode(Deeplink.self, from: data)

        XCTAssertEqual(decoded.name, "Khan Bank")
        XCTAssertEqual(decoded.link, "khanbank://pay?q=abc")
    }

    func testOffsetCodingKeys() throws {
        let offset = Offset(pageNumber: 2, pageLimit: 25)

        let data = try encoder.encode(offset)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["page_number"] as? Int, 2)
        XCTAssertEqual(dict["page_limit"] as? Int, 25)
    }

    // MARK: - CardTransaction

    func testCardTransactionDecoding() throws {
        let json = """
        {
            "card_merchant_code": "MC001",
            "card_terminal_code": "T001",
            "card_number": "4111****1111",
            "card_type": "VISA",
            "is_cross_border": false,
            "amount": "1000",
            "transaction_amount": "1000",
            "currency": "MNT",
            "transaction_currency": "MNT",
            "date": "2024-01-15",
            "transaction_date": "2024-01-15",
            "status": "SUCCESS",
            "transaction_status": "APPROVED",
            "settlement_status": "SETTLED",
            "settlement_status_date": "2024-01-16"
        }
        """.data(using: .utf8)!

        let txn = try decoder.decode(CardTransaction.self, from: json)
        XCTAssertEqual(txn.cardType, "VISA")
        XCTAssertFalse(txn.isCrossBorder)
        XCTAssertEqual(txn.settlementStatus, "SETTLED")
        XCTAssertEqual(txn.cardNumber, "4111****1111")
    }

    // MARK: - AnyCodable

    func testAnyCodableStringRoundtrip() throws {
        let value = AnyCodable("hello")
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? String, "hello")
    }

    func testAnyCodableIntRoundtrip() throws {
        let value = AnyCodable(42)
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Int, 42)
    }

    func testAnyCodableBoolRoundtrip() throws {
        let value = AnyCodable(true)
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Bool, true)
    }

    func testAnyCodableDoubleRoundtrip() throws {
        let value = AnyCodable(3.14)
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Double, 3.14)
    }

    func testAnyCodableNullDecoding() throws {
        let json = "null".data(using: .utf8)!
        let decoded = try decoder.decode(AnyCodable.self, from: json)
        XCTAssertTrue(decoded.value is NSNull)
    }
}
