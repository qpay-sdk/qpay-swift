import Foundation

// MARK: - PaymentCheckRequest

/// Request to check if a payment has been made for an invoice.
public struct PaymentCheckRequest: Codable, Sendable {
    public let objectType: String
    public let objectID: String
    public var offset: Offset?

    enum CodingKeys: String, CodingKey {
        case objectType = "object_type"
        case objectID = "object_id"
        case offset
    }

    public init(
        objectType: String,
        objectID: String,
        offset: Offset? = nil
    ) {
        self.objectType = objectType
        self.objectID = objectID
        self.offset = offset
    }
}

// MARK: - PaymentCheckResponse

/// Response from payment check.
public struct PaymentCheckResponse: Codable, Sendable {
    public let count: Int
    public let paidAmount: Double?
    public let rows: [PaymentCheckRow]

    enum CodingKeys: String, CodingKey {
        case count
        case paidAmount = "paid_amount"
        case rows
    }
}

// MARK: - PaymentCheckRow

public struct PaymentCheckRow: Codable, Sendable {
    public let paymentID: String
    public let paymentStatus: String
    public let paymentAmount: String
    public let trxFee: String
    public let paymentCurrency: String
    public let paymentWallet: String
    public let paymentType: String
    public let nextPaymentDate: String?
    public let nextPaymentDatetime: String?
    public let cardTransactions: [CardTransaction]
    public let p2pTransactions: [P2PTransaction]

    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case paymentStatus = "payment_status"
        case paymentAmount = "payment_amount"
        case trxFee = "trx_fee"
        case paymentCurrency = "payment_currency"
        case paymentWallet = "payment_wallet"
        case paymentType = "payment_type"
        case nextPaymentDate = "next_payment_date"
        case nextPaymentDatetime = "next_payment_datetime"
        case cardTransactions = "card_transactions"
        case p2pTransactions = "p2p_transactions"
    }
}

// MARK: - PaymentDetail

/// Detailed payment information.
public struct PaymentDetail: Codable, Sendable {
    public let paymentID: String
    public let paymentStatus: String
    public let paymentFee: String
    public let paymentAmount: String
    public let paymentCurrency: String
    public let paymentDate: String
    public let paymentWallet: String
    public let transactionType: String
    public let objectType: String
    public let objectID: String
    public let nextPaymentDate: String?
    public let nextPaymentDatetime: String?
    public let cardTransactions: [CardTransaction]
    public let p2pTransactions: [P2PTransaction]

    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case paymentStatus = "payment_status"
        case paymentFee = "payment_fee"
        case paymentAmount = "payment_amount"
        case paymentCurrency = "payment_currency"
        case paymentDate = "payment_date"
        case paymentWallet = "payment_wallet"
        case transactionType = "transaction_type"
        case objectType = "object_type"
        case objectID = "object_id"
        case nextPaymentDate = "next_payment_date"
        case nextPaymentDatetime = "next_payment_datetime"
        case cardTransactions = "card_transactions"
        case p2pTransactions = "p2p_transactions"
    }
}

// MARK: - CardTransaction

public struct CardTransaction: Codable, Sendable {
    public let cardMerchantCode: String?
    public let cardTerminalCode: String?
    public let cardNumber: String?
    public let cardType: String
    public let isCrossBorder: Bool
    public let amount: String?
    public let transactionAmount: String?
    public let currency: String?
    public let transactionCurrency: String?
    public let date: String?
    public let transactionDate: String?
    public let status: String?
    public let transactionStatus: String?
    public let settlementStatus: String
    public let settlementStatusDate: String

    enum CodingKeys: String, CodingKey {
        case cardMerchantCode = "card_merchant_code"
        case cardTerminalCode = "card_terminal_code"
        case cardNumber = "card_number"
        case cardType = "card_type"
        case isCrossBorder = "is_cross_border"
        case amount
        case transactionAmount = "transaction_amount"
        case currency
        case transactionCurrency = "transaction_currency"
        case date
        case transactionDate = "transaction_date"
        case status
        case transactionStatus = "transaction_status"
        case settlementStatus = "settlement_status"
        case settlementStatusDate = "settlement_status_date"
    }
}

// MARK: - P2PTransaction

public struct P2PTransaction: Codable, Sendable {
    public let transactionBankCode: String
    public let accountBankCode: String
    public let accountBankName: String
    public let accountNumber: String
    public let status: String
    public let amount: String
    public let currency: String
    public let settlementStatus: String

    enum CodingKeys: String, CodingKey {
        case transactionBankCode = "transaction_bank_code"
        case accountBankCode = "account_bank_code"
        case accountBankName = "account_bank_name"
        case accountNumber = "account_number"
        case status
        case amount
        case currency
        case settlementStatus = "settlement_status"
    }
}

// MARK: - PaymentListRequest

/// Request to list payments with filtering.
public struct PaymentListRequest: Codable, Sendable {
    public let objectType: String
    public let objectID: String
    public let startDate: String
    public let endDate: String
    public let offset: Offset

    enum CodingKeys: String, CodingKey {
        case objectType = "object_type"
        case objectID = "object_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case offset
    }

    public init(
        objectType: String,
        objectID: String,
        startDate: String,
        endDate: String,
        offset: Offset
    ) {
        self.objectType = objectType
        self.objectID = objectID
        self.startDate = startDate
        self.endDate = endDate
        self.offset = offset
    }
}

// MARK: - PaymentListResponse

/// Response from listing payments.
public struct PaymentListResponse: Codable, Sendable {
    public let count: Int
    public let rows: [PaymentListItem]
}

// MARK: - PaymentListItem

public struct PaymentListItem: Codable, Sendable {
    public let paymentID: String
    public let paymentDate: String
    public let paymentStatus: String
    public let paymentFee: String
    public let paymentAmount: String
    public let paymentCurrency: String
    public let paymentWallet: String
    public let paymentName: String
    public let paymentDescription: String
    public let qrCode: String
    public let paidBy: String
    public let objectType: String
    public let objectID: String

    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case paymentDate = "payment_date"
        case paymentStatus = "payment_status"
        case paymentFee = "payment_fee"
        case paymentAmount = "payment_amount"
        case paymentCurrency = "payment_currency"
        case paymentWallet = "payment_wallet"
        case paymentName = "payment_name"
        case paymentDescription = "payment_description"
        case qrCode = "qr_code"
        case paidBy = "paid_by"
        case objectType = "object_type"
        case objectID = "object_id"
    }
}

// MARK: - PaymentCancelRequest

/// Request to cancel a payment.
public struct PaymentCancelRequest: Codable, Sendable {
    public var callbackURL: String?
    public var note: String?

    enum CodingKeys: String, CodingKey {
        case callbackURL = "callback_url"
        case note
    }

    public init(
        callbackURL: String? = nil,
        note: String? = nil
    ) {
        self.callbackURL = callbackURL
        self.note = note
    }
}

// MARK: - PaymentRefundRequest

/// Request to refund a payment.
public struct PaymentRefundRequest: Codable, Sendable {
    public var callbackURL: String?
    public var note: String?

    enum CodingKeys: String, CodingKey {
        case callbackURL = "callback_url"
        case note
    }

    public init(
        callbackURL: String? = nil,
        note: String? = nil
    ) {
        self.callbackURL = callbackURL
        self.note = note
    }
}
