import Foundation

// MARK: - CreateEbarimtRequest

/// Request to create an ebarimt (electronic tax receipt) for a payment.
public struct CreateEbarimtRequest: Codable, Sendable {
    public let paymentID: String
    public let ebarimtReceiverType: String
    public var ebarimtReceiver: String?
    public var districtCode: String?
    public var classificationCode: String?

    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case ebarimtReceiverType = "ebarimt_receiver_type"
        case ebarimtReceiver = "ebarimt_receiver"
        case districtCode = "district_code"
        case classificationCode = "classification_code"
    }

    public init(
        paymentID: String,
        ebarimtReceiverType: String,
        ebarimtReceiver: String? = nil,
        districtCode: String? = nil,
        classificationCode: String? = nil
    ) {
        self.paymentID = paymentID
        self.ebarimtReceiverType = ebarimtReceiverType
        self.ebarimtReceiver = ebarimtReceiver
        self.districtCode = districtCode
        self.classificationCode = classificationCode
    }
}

// MARK: - EbarimtResponse

/// Response from ebarimt creation or cancellation.
public struct EbarimtResponse: Codable, Sendable {
    public let id: String
    public let ebarimtBy: String
    public let gWalletID: String
    public let gWalletCustomerID: String
    public let ebarimtReceiverType: String
    public let ebarimtReceiver: String
    public let ebarimtDistrictCode: String
    public let ebarimtBillType: String
    public let gMerchantID: String
    public let merchantBranchCode: String
    public let merchantTerminalCode: String?
    public let merchantStaffCode: String?
    public let merchantRegisterNo: String
    public let gPaymentID: String
    public let paidBy: String
    public let objectType: String
    public let objectID: String
    public let amount: String
    public let vatAmount: String
    public let cityTaxAmount: String
    public let ebarimtQRData: String
    public let ebarimtLottery: String
    public let note: String?
    public let barimtStatus: String
    public let barimtStatusDate: String
    public let ebarimtSentEmail: String?
    public let ebarimtReceiverPhone: String
    public let taxType: String
    public let merchantTIN: String?
    public let ebarimtReceiptID: String?
    public let createdBy: String
    public let createdDate: String
    public let updatedBy: String
    public let updatedDate: String
    public let status: Bool
    public let barimtItems: [EbarimtItem]?
    public let barimtTransactions: [AnyCodable]?
    public let barimtHistories: [EbarimtHistory]?

    enum CodingKeys: String, CodingKey {
        case id
        case ebarimtBy = "ebarimt_by"
        case gWalletID = "g_wallet_id"
        case gWalletCustomerID = "g_wallet_customer_id"
        case ebarimtReceiverType = "ebarimt_receiver_type"
        case ebarimtReceiver = "ebarimt_receiver"
        case ebarimtDistrictCode = "ebarimt_district_code"
        case ebarimtBillType = "ebarimt_bill_type"
        case gMerchantID = "g_merchant_id"
        case merchantBranchCode = "merchant_branch_code"
        case merchantTerminalCode = "merchant_terminal_code"
        case merchantStaffCode = "merchant_staff_code"
        case merchantRegisterNo = "merchant_register_no"
        case gPaymentID = "g_payment_id"
        case paidBy = "paid_by"
        case objectType = "object_type"
        case objectID = "object_id"
        case amount
        case vatAmount = "vat_amount"
        case cityTaxAmount = "city_tax_amount"
        case ebarimtQRData = "ebarimt_qr_data"
        case ebarimtLottery = "ebarimt_lottery"
        case note
        case barimtStatus = "barimt_status"
        case barimtStatusDate = "barimt_status_date"
        case ebarimtSentEmail = "ebarimt_sent_email"
        case ebarimtReceiverPhone = "ebarimt_receiver_phone"
        case taxType = "tax_type"
        case merchantTIN = "merchant_tin"
        case ebarimtReceiptID = "ebarimt_receipt_id"
        case createdBy = "created_by"
        case createdDate = "created_date"
        case updatedBy = "updated_by"
        case updatedDate = "updated_date"
        case status
        case barimtItems = "barimt_items"
        case barimtTransactions = "barimt_transactions"
        case barimtHistories = "barimt_histories"
    }
}

// MARK: - EbarimtItem

public struct EbarimtItem: Codable, Sendable {
    public let id: String
    public let barimtID: String
    public let merchantProductCode: String?
    public let taxProductCode: String
    public let barCode: String?
    public let name: String
    public let unitPrice: String
    public let quantity: String
    public let amount: String
    public let cityTaxAmount: String
    public let vatAmount: String
    public let note: String?
    public let createdBy: String
    public let createdDate: String
    public let updatedBy: String
    public let updatedDate: String
    public let status: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case barimtID = "barimt_id"
        case merchantProductCode = "merchant_product_code"
        case taxProductCode = "tax_product_code"
        case barCode = "bar_code"
        case name
        case unitPrice = "unit_price"
        case quantity
        case amount
        case cityTaxAmount = "city_tax_amount"
        case vatAmount = "vat_amount"
        case note
        case createdBy = "created_by"
        case createdDate = "created_date"
        case updatedBy = "updated_by"
        case updatedDate = "updated_date"
        case status
    }
}

// MARK: - EbarimtHistory

public struct EbarimtHistory: Codable, Sendable {
    public let id: String
    public let barimtID: String
    public let ebarimtReceiverType: String
    public let ebarimtReceiver: String
    public let ebarimtRegisterNo: String?
    public let ebarimtBillID: String
    public let ebarimtDate: String
    public let ebarimtMacAddress: String
    public let ebarimtInternalCode: String
    public let ebarimtBillType: String
    public let ebarimtQRData: String
    public let ebarimtLottery: String
    public let ebarimtLotteryMsg: String?
    public let ebarimtErrorCode: String?
    public let ebarimtErrorMsg: String?
    public let ebarimtResponseCode: String?
    public let ebarimtResponseMsg: String?
    public let note: String?
    public let barimtStatus: String
    public let barimtStatusDate: String
    public let ebarimtSentEmail: String?
    public let ebarimtReceiverPhone: String
    public let taxType: String
    public let createdBy: String
    public let createdDate: String
    public let updatedBy: String
    public let updatedDate: String
    public let status: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case barimtID = "barimt_id"
        case ebarimtReceiverType = "ebarimt_receiver_type"
        case ebarimtReceiver = "ebarimt_receiver"
        case ebarimtRegisterNo = "ebarimt_register_no"
        case ebarimtBillID = "ebarimt_bill_id"
        case ebarimtDate = "ebarimt_date"
        case ebarimtMacAddress = "ebarimt_mac_address"
        case ebarimtInternalCode = "ebarimt_internal_code"
        case ebarimtBillType = "ebarimt_bill_type"
        case ebarimtQRData = "ebarimt_qr_data"
        case ebarimtLottery = "ebarimt_lottery"
        case ebarimtLotteryMsg = "ebarimt_lottery_msg"
        case ebarimtErrorCode = "ebarimt_error_code"
        case ebarimtErrorMsg = "ebarimt_error_msg"
        case ebarimtResponseCode = "ebarimt_response_code"
        case ebarimtResponseMsg = "ebarimt_response_msg"
        case note
        case barimtStatus = "barimt_status"
        case barimtStatusDate = "barimt_status_date"
        case ebarimtSentEmail = "ebarimt_sent_email"
        case ebarimtReceiverPhone = "ebarimt_receiver_phone"
        case taxType = "tax_type"
        case createdBy = "created_by"
        case createdDate = "created_date"
        case updatedBy = "updated_by"
        case updatedDate = "updated_date"
        case status
    }
}

// MARK: - AnyCodable

/// A type-erased Codable value, used for fields with heterogeneous JSON arrays.
public struct AnyCodable: Codable, @unchecked Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value is NSNull {
            try container.encodeNil()
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            try container.encode(dict.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
