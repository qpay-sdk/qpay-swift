import Foundation

/// A custom URLProtocol subclass that intercepts all HTTP requests for testing.
///
/// Usage:
/// ```swift
/// MockURLProtocol.requestHandler = { request in
///     let response = HTTPURLResponse(
///         url: request.url!,
///         statusCode: 200,
///         httpVersion: nil,
///         headerFields: nil
///     )!
///     let data = """{"key": "value"}""".data(using: .utf8)!
///     return (response, data)
/// }
/// ```
final class MockURLProtocol: URLProtocol {

    /// Handler that returns a mock response for each request.
    /// Set this before making requests through a session using this protocol.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Stores the most recent request for inspection in tests.
    static var lastRequest: URLRequest?

    /// Stores all captured requests for inspection in tests.
    static var capturedRequests: [URLRequest] = []

    /// Resets all state. Call this in setUp/tearDown.
    static func reset() {
        requestHandler = nil
        lastRequest = nil
        capturedRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        MockURLProtocol.lastRequest = request
        MockURLProtocol.capturedRequests.append(request)

        guard let handler = MockURLProtocol.requestHandler else {
            let error = NSError(
                domain: "MockURLProtocol",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No request handler set"]
            )
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // No-op
    }
}

/// Creates a URLSession configured to use MockURLProtocol.
func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}
