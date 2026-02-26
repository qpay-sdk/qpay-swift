import Foundation

// MARK: - Address

public struct Address: Codable, Sendable {
    public var city: String?
    public var district: String?
    public var street: String?
    public var building: String?
    public var address: String?
    public var zipcode: String?
    public var longitude: String?
    public var latitude: String?

    public init(
        city: String? = nil,
        district: String? = nil,
        street: String? = nil,
        building: String? = nil,
        address: String? = nil,
        zipcode: String? = nil,
        longitude: String? = nil,
        latitude: String? = nil
    ) {
        self.city = city
        self.district = district
        self.street = street
        self.building = building
        self.address = address
        self.zipcode = zipcode
        self.longitude = longitude
        self.latitude = latitude
    }
}

// MARK: - SenderBranchData

public struct SenderBranchData: Codable, Sendable {
    public var register: String?
    public var name: String?
    public var email: String?
    public var phone: String?
    public var address: Address?

    public init(
        register: String? = nil,
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        address: Address? = nil
    ) {
        self.register = register
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
    }
}

// MARK: - SenderStaffData

public struct SenderStaffData: Codable, Sendable {
    public var name: String?
    public var email: String?
    public var phone: String?

    public init(
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
    }
}

// MARK: - InvoiceReceiverData

public struct InvoiceReceiverData: Codable, Sendable {
    public var register: String?
    public var name: String?
    public var email: String?
    public var phone: String?
    public var address: Address?

    public init(
        register: String? = nil,
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        address: Address? = nil
    ) {
        self.register = register
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
    }
}

// MARK: - Account

public struct Account: Codable, Sendable {
    public let accountBankCode: String
    public let accountNumber: String
    public let ibanNumber: String
    public let accountName: String
    public let accountCurrency: String
    public let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case accountBankCode = "account_bank_code"
        case accountNumber = "account_number"
        case ibanNumber = "iban_number"
        case accountName = "account_name"
        case accountCurrency = "account_currency"
        case isDefault = "is_default"
    }

    public init(
        accountBankCode: String,
        accountNumber: String,
        ibanNumber: String,
        accountName: String,
        accountCurrency: String,
        isDefault: Bool
    ) {
        self.accountBankCode = accountBankCode
        self.accountNumber = accountNumber
        self.ibanNumber = ibanNumber
        self.accountName = accountName
        self.accountCurrency = accountCurrency
        self.isDefault = isDefault
    }
}

// MARK: - Transaction

public struct Transaction: Codable, Sendable {
    public let description: String
    public let amount: String
    public var accounts: [Account]?

    public init(
        description: String,
        amount: String,
        accounts: [Account]? = nil
    ) {
        self.description = description
        self.amount = amount
        self.accounts = accounts
    }
}

// MARK: - TaxEntry

public struct TaxEntry: Codable, Sendable {
    public var taxCode: String?
    public var discountCode: String?
    public var surchargeCode: String?
    public let description: String
    public let amount: Double
    public var note: String?

    enum CodingKeys: String, CodingKey {
        case taxCode = "tax_code"
        case discountCode = "discount_code"
        case surchargeCode = "surcharge_code"
        case description
        case amount
        case note
    }

    public init(
        taxCode: String? = nil,
        discountCode: String? = nil,
        surchargeCode: String? = nil,
        description: String,
        amount: Double,
        note: String? = nil
    ) {
        self.taxCode = taxCode
        self.discountCode = discountCode
        self.surchargeCode = surchargeCode
        self.description = description
        self.amount = amount
        self.note = note
    }
}

// MARK: - InvoiceLine

public struct InvoiceLine: Codable, Sendable {
    public var taxProductCode: String?
    public let lineDescription: String
    public let lineQuantity: String
    public let lineUnitPrice: String
    public var note: String?
    public var discounts: [TaxEntry]?
    public var surcharges: [TaxEntry]?
    public var taxes: [TaxEntry]?

    enum CodingKeys: String, CodingKey {
        case taxProductCode = "tax_product_code"
        case lineDescription = "line_description"
        case lineQuantity = "line_quantity"
        case lineUnitPrice = "line_unit_price"
        case note
        case discounts
        case surcharges
        case taxes
    }

    public init(
        taxProductCode: String? = nil,
        lineDescription: String,
        lineQuantity: String,
        lineUnitPrice: String,
        note: String? = nil,
        discounts: [TaxEntry]? = nil,
        surcharges: [TaxEntry]? = nil,
        taxes: [TaxEntry]? = nil
    ) {
        self.taxProductCode = taxProductCode
        self.lineDescription = lineDescription
        self.lineQuantity = lineQuantity
        self.lineUnitPrice = lineUnitPrice
        self.note = note
        self.discounts = discounts
        self.surcharges = surcharges
        self.taxes = taxes
    }
}

// MARK: - EbarimtInvoiceLine

public struct EbarimtInvoiceLine: Codable, Sendable {
    public var taxProductCode: String?
    public let lineDescription: String
    public var barcode: String?
    public let lineQuantity: String
    public let lineUnitPrice: String
    public var note: String?
    public var classificationCode: String?
    public var taxes: [TaxEntry]?

    enum CodingKeys: String, CodingKey {
        case taxProductCode = "tax_product_code"
        case lineDescription = "line_description"
        case barcode
        case lineQuantity = "line_quantity"
        case lineUnitPrice = "line_unit_price"
        case note
        case classificationCode = "classification_code"
        case taxes
    }

    public init(
        taxProductCode: String? = nil,
        lineDescription: String,
        barcode: String? = nil,
        lineQuantity: String,
        lineUnitPrice: String,
        note: String? = nil,
        classificationCode: String? = nil,
        taxes: [TaxEntry]? = nil
    ) {
        self.taxProductCode = taxProductCode
        self.lineDescription = lineDescription
        self.barcode = barcode
        self.lineQuantity = lineQuantity
        self.lineUnitPrice = lineUnitPrice
        self.note = note
        self.classificationCode = classificationCode
        self.taxes = taxes
    }
}

// MARK: - Deeplink

public struct Deeplink: Codable, Sendable {
    public let name: String
    public let description: String
    public let logo: String
    public let link: String

    public init(
        name: String,
        description: String,
        logo: String,
        link: String
    ) {
        self.name = name
        self.description = description
        self.logo = logo
        self.link = link
    }
}

// MARK: - Offset

public struct Offset: Codable, Sendable {
    public let pageNumber: Int
    public let pageLimit: Int

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page_number"
        case pageLimit = "page_limit"
    }

    public init(pageNumber: Int, pageLimit: Int) {
        self.pageNumber = pageNumber
        self.pageLimit = pageLimit
    }
}
