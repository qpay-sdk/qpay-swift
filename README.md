# QPay Swift SDK

A Swift SDK for the QPay V2 payment API. Supports iOS 15+ and macOS 12+.

Built with Swift concurrency (async/await) and actor isolation for thread-safe token management.

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/qpay-swift.git", from: "1.0.0")
]
```

Then add `"QPay"` to your target's dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["QPay"]
)
```

### Xcode

1. Open your project in Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/your-org/qpay-swift.git`
4. Select the version rule and click **Add Package**
5. Select the `QPay` library and add it to your target

## Quick Start

```swift
import QPay

// 1. Create configuration
let config = QPayConfig(
    baseURL: "https://merchant.qpay.mn",
    username: "YOUR_USERNAME",
    password: "YOUR_PASSWORD",
    invoiceCode: "YOUR_INVOICE_CODE",
    callbackURL: "https://yoursite.com/qpay/callback"
)

// 2. Create client
let client = QPayClient(config: config)

// 3. Create an invoice
let invoice = try await client.createSimpleInvoice(
    CreateSimpleInvoiceRequest(
        invoiceCode: config.invoiceCode,
        senderInvoiceNo: "ORDER-001",
        invoiceReceiverCode: "terminal",
        invoiceDescription: "Payment for Order #001",
        amount: 50000,
        callbackURL: config.callbackURL
    )
)

print("Invoice ID: \(invoice.invoiceID)")
print("QR Image: \(invoice.qrImage)")
print("Short URL: \(invoice.qPayShortURL)")

// 4. Check payment status
let check = try await client.checkPayment(
    PaymentCheckRequest(objectType: "INVOICE", objectID: invoice.invoiceID)
)

if check.count > 0 {
    print("Payment received! Amount: \(check.paidAmount ?? 0)")
}
```

## Configuration

### Direct Initialization

```swift
let config = QPayConfig(
    baseURL: "https://merchant.qpay.mn",
    username: "YOUR_USERNAME",
    password: "YOUR_PASSWORD",
    invoiceCode: "YOUR_INVOICE_CODE",
    callbackURL: "https://yoursite.com/qpay/callback"
)
```

### From Environment Variables

For server-side Swift applications, you can load configuration from environment variables:

```swift
// Requires these environment variables to be set:
// - QPAY_BASE_URL
// - QPAY_USERNAME
// - QPAY_PASSWORD
// - QPAY_INVOICE_CODE
// - QPAY_CALLBACK_URL

let config = try QPayConfig.fromEnvironment()
```

If any required variable is missing or empty, a `QPayError.configMissing` error is thrown.

## Usage

### Authentication

The client handles token management automatically. Tokens are obtained, cached, and refreshed as needed before each API call. You do not need to call `getToken()` manually.

If you need explicit control:

```swift
// Get a new token
let token = try await client.getToken()

// Refresh the current token
let refreshed = try await client.refreshTokenCall()
```

### Create a Simple Invoice

```swift
let invoice = try await client.createSimpleInvoice(
    CreateSimpleInvoiceRequest(
        invoiceCode: "YOUR_INVOICE_CODE",
        senderInvoiceNo: "ORDER-001",
        invoiceReceiverCode: "terminal",
        invoiceDescription: "Payment for Order #001",
        amount: 50000,
        callbackURL: "https://yoursite.com/qpay/callback"
    )
)

// invoice.invoiceID     — Invoice ID for payment checking
// invoice.qrText        — QR code text data
// invoice.qrImage       — Base64-encoded QR code image
// invoice.qPayShortURL  — Short URL for payment
// invoice.urls          — Array of bank app deeplinks
```

### Create a Full Invoice

```swift
let invoice = try await client.createInvoice(
    CreateInvoiceRequest(
        invoiceCode: "YOUR_INVOICE_CODE",
        senderInvoiceNo: "ORDER-002",
        senderBranchCode: "BRANCH_001",
        senderBranchData: SenderBranchData(
            register: "REG001",
            name: "Main Branch",
            email: "branch@company.mn",
            phone: "77001122"
        ),
        invoiceReceiverCode: "terminal",
        invoiceReceiverData: InvoiceReceiverData(
            register: "CUST001",
            name: "Customer Name",
            email: "customer@example.mn",
            phone: "99001122"
        ),
        invoiceDescription: "Order #002 with details",
        enableExpiry: "true",
        allowPartial: false,
        allowExceed: false,
        amount: 100000,
        callbackURL: "https://yoursite.com/qpay/callback",
        note: "VIP customer order",
        lines: [
            InvoiceLine(
                taxProductCode: "PROD001",
                lineDescription: "Widget A",
                lineQuantity: "2",
                lineUnitPrice: "25000"
            ),
            InvoiceLine(
                taxProductCode: "PROD002",
                lineDescription: "Widget B",
                lineQuantity: "1",
                lineUnitPrice: "50000"
            )
        ]
    )
)
```

### Create an Invoice with Ebarimt (Tax)

```swift
let invoice = try await client.createEbarimtInvoice(
    CreateEbarimtInvoiceRequest(
        invoiceCode: "YOUR_INVOICE_CODE",
        senderInvoiceNo: "ORDER-003",
        invoiceReceiverCode: "terminal",
        invoiceDescription: "Taxed order",
        taxType: "1",
        districtCode: "34",
        callbackURL: "https://yoursite.com/qpay/callback",
        lines: [
            EbarimtInvoiceLine(
                taxProductCode: "TAX001",
                lineDescription: "Taxable Product",
                lineQuantity: "1",
                lineUnitPrice: "75000"
            )
        ]
    )
)
```

### Cancel an Invoice

```swift
try await client.cancelInvoice(invoiceID: "INVOICE_ID")
```

### Get Payment Details

```swift
let payment = try await client.getPayment(paymentID: "PAYMENT_ID")

print("Status: \(payment.paymentStatus)")
print("Amount: \(payment.paymentAmount)")
print("Wallet: \(payment.paymentWallet)")
```

### Check Payment Status

```swift
let check = try await client.checkPayment(
    PaymentCheckRequest(
        objectType: "INVOICE",
        objectID: "INVOICE_ID",
        offset: Offset(pageNumber: 1, pageLimit: 10)
    )
)

for row in check.rows {
    print("Payment \(row.paymentID): \(row.paymentStatus) - \(row.paymentAmount) MNT")
}
```

### List Payments

```swift
let list = try await client.listPayments(
    PaymentListRequest(
        objectType: "INVOICE",
        objectID: "INVOICE_ID",
        startDate: "2024-01-01",
        endDate: "2024-12-31",
        offset: Offset(pageNumber: 1, pageLimit: 20)
    )
)

print("Total: \(list.count)")
for item in list.rows {
    print("\(item.paymentID) - \(item.paymentAmount) \(item.paymentCurrency)")
}
```

### Cancel a Payment

```swift
// Without additional data
try await client.cancelPayment(paymentID: "PAYMENT_ID")

// With callback URL and note
try await client.cancelPayment(
    paymentID: "PAYMENT_ID",
    request: PaymentCancelRequest(
        callbackURL: "https://yoursite.com/qpay/cancel-callback",
        note: "Customer requested cancellation"
    )
)
```

### Refund a Payment

```swift
// Without additional data
try await client.refundPayment(paymentID: "PAYMENT_ID")

// With callback URL and note
try await client.refundPayment(
    paymentID: "PAYMENT_ID",
    request: PaymentRefundRequest(
        callbackURL: "https://yoursite.com/qpay/refund-callback",
        note: "Product returned"
    )
)
```

### Create an Ebarimt (Tax Receipt)

```swift
let ebarimt = try await client.createEbarimt(
    CreateEbarimtRequest(
        paymentID: "PAYMENT_ID",
        ebarimtReceiverType: "individual",
        ebarimtReceiver: "AA12345678",
        districtCode: "34"
    )
)

print("Ebarimt ID: \(ebarimt.id)")
print("Lottery: \(ebarimt.ebarimtLottery)")
print("QR Data: \(ebarimt.ebarimtQRData)")
```

### Cancel an Ebarimt

```swift
let canceled = try await client.cancelEbarimt(paymentID: "PAYMENT_ID")
print("Status: \(canceled.barimtStatus)")
```

## Error Handling

All methods throw `QPayError`, which provides detailed error information:

```swift
do {
    let invoice = try await client.createSimpleInvoice(request)
} catch let error as QPayError {
    switch error {
    case .configMissing(let variable):
        print("Missing config: \(variable)")

    case .apiError(let statusCode, let code, let message, let rawBody):
        print("API error \(statusCode): \(code) - \(message)")

        // Check specific error codes
        if code == QPayErrorCode.invoicePaid {
            print("This invoice has already been paid")
        } else if code == QPayErrorCode.authenticationFailed {
            print("Invalid credentials")
        }

    case .requestFailed(let reason):
        print("Request failed: \(reason)")

    case .decodingFailed(let reason):
        print("Could not parse response: \(reason)")

    case .encodingFailed(let reason):
        print("Could not encode request: \(reason)")

    case .unexpected(let reason):
        print("Unexpected: \(reason)")
    }
}
```

### Convenience Properties

```swift
if let error = error as? QPayError {
    error.code        // API error code string, or nil
    error.statusCode  // HTTP status code, or nil
    error.rawBody     // Raw response body, or nil
}
```

### Error Code Constants

Use `QPayErrorCode` constants for reliable comparisons:

```swift
if error.code == QPayErrorCode.invoiceNotFound { ... }
if error.code == QPayErrorCode.paymentAlreadyCanceled { ... }
if error.code == QPayErrorCode.permissionDenied { ... }
if error.code == QPayErrorCode.invalidAmount { ... }
```

See `ErrorCodes.swift` for the complete list of error code constants.

## iOS / macOS Integration

### SwiftUI Example

```swift
import SwiftUI
import QPay

struct PaymentView: View {
    @State private var qrImage: UIImage?
    @State private var invoiceID: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    let client: QPayClient

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Creating invoice...")
            }

            if let qrImage {
                Image(uiImage: qrImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Pay 50,000 MNT") {
                Task { await createInvoice() }
            }
            .disabled(isLoading)

            if invoiceID != nil {
                Button("Check Payment") {
                    Task { await checkPayment() }
                }
            }
        }
        .padding()
    }

    func createInvoice() async {
        isLoading = true
        errorMessage = nil

        do {
            let invoice = try await client.createSimpleInvoice(
                CreateSimpleInvoiceRequest(
                    invoiceCode: "YOUR_CODE",
                    senderInvoiceNo: "APP-\(UUID().uuidString.prefix(8))",
                    invoiceReceiverCode: "terminal",
                    invoiceDescription: "In-app purchase",
                    amount: 50000,
                    callbackURL: "https://yoursite.com/callback"
                )
            )

            invoiceID = invoice.invoiceID

            // Decode base64 QR image
            if let data = Data(base64Encoded: invoice.qrImage) {
                qrImage = UIImage(data: data)
            }
        } catch let error as QPayError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func checkPayment() async {
        guard let invoiceID else { return }

        do {
            let check = try await client.checkPayment(
                PaymentCheckRequest(objectType: "INVOICE", objectID: invoiceID)
            )
            if check.count > 0 {
                errorMessage = nil
                // Payment received - navigate to success screen
            } else {
                errorMessage = "Payment not yet received"
            }
        } catch let error as QPayError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### Opening Bank Apps via Deeplinks

The invoice response includes deeplinks for installed banking apps:

```swift
let invoice = try await client.createSimpleInvoice(request)

for deeplink in invoice.urls {
    print("\(deeplink.name): \(deeplink.link)")
}

// Open a specific bank app (iOS)
if let url = URL(string: invoice.urls.first?.link ?? "") {
    await UIApplication.shared.open(url)
}
```

## API Reference

### QPayClient Methods

| Method | Description |
|---|---|
| `getToken()` | Authenticate and get a new token pair |
| `refreshTokenCall()` | Refresh the current access token |
| `createInvoice(_:)` | Create a full invoice with all options |
| `createSimpleInvoice(_:)` | Create a simple invoice with minimal fields |
| `createEbarimtInvoice(_:)` | Create an invoice with ebarimt (tax) data |
| `cancelInvoice(invoiceID:)` | Cancel an invoice |
| `getPayment(paymentID:)` | Get payment details |
| `checkPayment(_:)` | Check payment status for an invoice |
| `listPayments(_:)` | List payments with date range filtering |
| `cancelPayment(paymentID:request:)` | Cancel a card payment |
| `refundPayment(paymentID:request:)` | Refund a card payment |
| `createEbarimt(_:)` | Create a tax receipt for a payment |
| `cancelEbarimt(paymentID:)` | Cancel a tax receipt |

### Models

**Request models:**
- `CreateInvoiceRequest` -- Full invoice with all fields
- `CreateSimpleInvoiceRequest` -- Minimal invoice
- `CreateEbarimtInvoiceRequest` -- Invoice with tax data
- `PaymentCheckRequest` -- Check payment status
- `PaymentListRequest` -- List payments with filters
- `PaymentCancelRequest` -- Cancel payment options
- `PaymentRefundRequest` -- Refund payment options
- `CreateEbarimtRequest` -- Create tax receipt

**Response models:**
- `TokenResponse` -- Authentication token data
- `InvoiceResponse` -- Invoice with QR code and deeplinks
- `PaymentDetail` -- Full payment details
- `PaymentCheckResponse` -- Payment check result with rows
- `PaymentListResponse` -- Paginated payment list
- `EbarimtResponse` -- Tax receipt data

**Common models:**
- `Address`, `SenderBranchData`, `SenderStaffData`, `InvoiceReceiverData`
- `Account`, `Transaction`, `TaxEntry`
- `InvoiceLine`, `EbarimtInvoiceLine`
- `Deeplink`, `Offset`
- `CardTransaction`, `P2PTransaction`

## Requirements

- Swift 5.9+
- iOS 15.0+ / macOS 12.0+

## License

MIT License. See [LICENSE](LICENSE) for details.
