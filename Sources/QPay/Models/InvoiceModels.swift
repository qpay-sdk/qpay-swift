import Foundation

// MARK: - CreateInvoiceRequest

/// Full invoice creation request with all available options.
public struct CreateInvoiceRequest: Codable, Sendable {
    public let invoiceCode: String
    public let senderInvoiceNo: String
    public var senderBranchCode: String?
    public var senderBranchData: SenderBranchData?
    public var senderStaffData: SenderStaffData?
    public var senderStaffCode: String?
    public let invoiceReceiverCode: String
    public var invoiceReceiverData: InvoiceReceiverData?
    public let invoiceDescription: String
    public var enableExpiry: String?
    public var allowPartial: Bool?
    public var minimumAmount: Double?
    public var allowExceed: Bool?
    public var maximumAmount: Double?
    public let amount: Double
    public let callbackURL: String
    public var senderTerminalCode: String?
    public var allowSubscribe: Bool?
    public var subscriptionInterval: String?
    public var subscriptionWebhook: String?
    public var note: String?
    public var transactions: [Transaction]?
    public var lines: [InvoiceLine]?

    enum CodingKeys: String, CodingKey {
        case invoiceCode = "invoice_code"
        case senderInvoiceNo = "sender_invoice_no"
        case senderBranchCode = "sender_branch_code"
        case senderBranchData = "sender_branch_data"
        case senderStaffData = "sender_staff_data"
        case senderStaffCode = "sender_staff_code"
        case invoiceReceiverCode = "invoice_receiver_code"
        case invoiceReceiverData = "invoice_receiver_data"
        case invoiceDescription = "invoice_description"
        case enableExpiry = "enable_expiry"
        case allowPartial = "allow_partial"
        case minimumAmount = "minimum_amount"
        case allowExceed = "allow_exceed"
        case maximumAmount = "maximum_amount"
        case amount
        case callbackURL = "callback_url"
        case senderTerminalCode = "sender_terminal_code"
        case allowSubscribe = "allow_subscribe"
        case subscriptionInterval = "subscription_interval"
        case subscriptionWebhook = "subscription_webhook"
        case note
        case transactions
        case lines
    }

    public init(
        invoiceCode: String,
        senderInvoiceNo: String,
        senderBranchCode: String? = nil,
        senderBranchData: SenderBranchData? = nil,
        senderStaffData: SenderStaffData? = nil,
        senderStaffCode: String? = nil,
        invoiceReceiverCode: String,
        invoiceReceiverData: InvoiceReceiverData? = nil,
        invoiceDescription: String,
        enableExpiry: String? = nil,
        allowPartial: Bool? = nil,
        minimumAmount: Double? = nil,
        allowExceed: Bool? = nil,
        maximumAmount: Double? = nil,
        amount: Double,
        callbackURL: String,
        senderTerminalCode: String? = nil,
        allowSubscribe: Bool? = nil,
        subscriptionInterval: String? = nil,
        subscriptionWebhook: String? = nil,
        note: String? = nil,
        transactions: [Transaction]? = nil,
        lines: [InvoiceLine]? = nil
    ) {
        self.invoiceCode = invoiceCode
        self.senderInvoiceNo = senderInvoiceNo
        self.senderBranchCode = senderBranchCode
        self.senderBranchData = senderBranchData
        self.senderStaffData = senderStaffData
        self.senderStaffCode = senderStaffCode
        self.invoiceReceiverCode = invoiceReceiverCode
        self.invoiceReceiverData = invoiceReceiverData
        self.invoiceDescription = invoiceDescription
        self.enableExpiry = enableExpiry
        self.allowPartial = allowPartial
        self.minimumAmount = minimumAmount
        self.allowExceed = allowExceed
        self.maximumAmount = maximumAmount
        self.amount = amount
        self.callbackURL = callbackURL
        self.senderTerminalCode = senderTerminalCode
        self.allowSubscribe = allowSubscribe
        self.subscriptionInterval = subscriptionInterval
        self.subscriptionWebhook = subscriptionWebhook
        self.note = note
        self.transactions = transactions
        self.lines = lines
    }
}

// MARK: - CreateSimpleInvoiceRequest

/// Simple invoice creation request with minimal fields.
public struct CreateSimpleInvoiceRequest: Codable, Sendable {
    public let invoiceCode: String
    public let senderInvoiceNo: String
    public let invoiceReceiverCode: String
    public let invoiceDescription: String
    public var senderBranchCode: String?
    public let amount: Double
    public let callbackURL: String

    enum CodingKeys: String, CodingKey {
        case invoiceCode = "invoice_code"
        case senderInvoiceNo = "sender_invoice_no"
        case invoiceReceiverCode = "invoice_receiver_code"
        case invoiceDescription = "invoice_description"
        case senderBranchCode = "sender_branch_code"
        case amount
        case callbackURL = "callback_url"
    }

    public init(
        invoiceCode: String,
        senderInvoiceNo: String,
        invoiceReceiverCode: String,
        invoiceDescription: String,
        senderBranchCode: String? = nil,
        amount: Double,
        callbackURL: String
    ) {
        self.invoiceCode = invoiceCode
        self.senderInvoiceNo = senderInvoiceNo
        self.invoiceReceiverCode = invoiceReceiverCode
        self.invoiceDescription = invoiceDescription
        self.senderBranchCode = senderBranchCode
        self.amount = amount
        self.callbackURL = callbackURL
    }
}

// MARK: - CreateEbarimtInvoiceRequest

/// Invoice creation request with ebarimt (tax) information.
public struct CreateEbarimtInvoiceRequest: Codable, Sendable {
    public let invoiceCode: String
    public let senderInvoiceNo: String
    public var senderBranchCode: String?
    public var senderStaffData: SenderStaffData?
    public var senderStaffCode: String?
    public let invoiceReceiverCode: String
    public var invoiceReceiverData: InvoiceReceiverData?
    public let invoiceDescription: String
    public let taxType: String
    public let districtCode: String
    public let callbackURL: String
    public let lines: [EbarimtInvoiceLine]

    enum CodingKeys: String, CodingKey {
        case invoiceCode = "invoice_code"
        case senderInvoiceNo = "sender_invoice_no"
        case senderBranchCode = "sender_branch_code"
        case senderStaffData = "sender_staff_data"
        case senderStaffCode = "sender_staff_code"
        case invoiceReceiverCode = "invoice_receiver_code"
        case invoiceReceiverData = "invoice_receiver_data"
        case invoiceDescription = "invoice_description"
        case taxType = "tax_type"
        case districtCode = "district_code"
        case callbackURL = "callback_url"
        case lines
    }

    public init(
        invoiceCode: String,
        senderInvoiceNo: String,
        senderBranchCode: String? = nil,
        senderStaffData: SenderStaffData? = nil,
        senderStaffCode: String? = nil,
        invoiceReceiverCode: String,
        invoiceReceiverData: InvoiceReceiverData? = nil,
        invoiceDescription: String,
        taxType: String,
        districtCode: String,
        callbackURL: String,
        lines: [EbarimtInvoiceLine]
    ) {
        self.invoiceCode = invoiceCode
        self.senderInvoiceNo = senderInvoiceNo
        self.senderBranchCode = senderBranchCode
        self.senderStaffData = senderStaffData
        self.senderStaffCode = senderStaffCode
        self.invoiceReceiverCode = invoiceReceiverCode
        self.invoiceReceiverData = invoiceReceiverData
        self.invoiceDescription = invoiceDescription
        self.taxType = taxType
        self.districtCode = districtCode
        self.callbackURL = callbackURL
        self.lines = lines
    }
}

// MARK: - InvoiceResponse

/// Response from invoice creation.
public struct InvoiceResponse: Codable, Sendable {
    public let invoiceID: String
    public let qrText: String
    public let qrImage: String
    public let qPayShortURL: String
    public let urls: [Deeplink]

    enum CodingKeys: String, CodingKey {
        case invoiceID = "invoice_id"
        case qrText = "qr_text"
        case qrImage = "qr_image"
        case qPayShortURL = "qPay_shortUrl"
        case urls
    }
}
