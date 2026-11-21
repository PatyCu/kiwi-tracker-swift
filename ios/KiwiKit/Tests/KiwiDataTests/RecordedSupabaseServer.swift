import Foundation
import Supabase
import Synchronization

@testable import KiwiData

/// Answers a backend's requests with recorded Supabase responses. Each test uses its own
/// host, so tests running in parallel don't share answers.
final class RecordedSupabaseServer: URLProtocol, @unchecked Sendable {
  typealias Answer = @Sendable (URLRequest, Data) throws -> (status: Int, body: String)

  private static let answers = Mutex<[String: Answer]>([:])

  /// A backend whose requests `answer` handles, keeping its session in `storage`. The SDK keys
  /// the stored session by host, so a later launch of the same app reuses the host.
  static func backend(
    host: String = newHost(),
    storage: some AuthLocalStorage = InMemorySessionStorage(),
    answer: @escaping Answer
  ) throws -> SupabaseBackend {
    answers.withLock { $0[host] = answer }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [RecordedSupabaseServer.self]
    return SupabaseBackend(
      config: try SupabaseConfig(url: "http://\(host)", publishableKey: "sb_publishable_test"),
      sessionStorage: storage,
      urlSession: URLSession(configuration: configuration)
    )
  }

  static func newHost() -> String { "\(UUID().uuidString.lowercased()).test" }

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() {}

  override func startLoading() {
    guard let url = request.url, let host = url.host(),
      let answer = Self.answers.withLock({ $0[host] })
    else {
      client?.urlProtocol(self, didFailWithError: URLError(.cannotFindHost))
      return
    }
    do {
      let (status, body) = try answer(request, Self.body(of: request))
      let response = HTTPURLResponse(
        url: url,
        statusCode: status,
        httpVersion: "HTTP/1.1",
        headerFields: [
          "Content-Type": "application/json", "X-Supabase-Api-Version": "2024-01-01",
        ]
      )
      if let response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      client?.urlProtocol(self, didLoad: Data(body.utf8))
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  /// URLSession hands protocols the body as a stream.
  private static func body(of request: URLRequest) -> Data {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return Data() }
    stream.open()
    defer { stream.close() }
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)
    while case let count = stream.read(&buffer, maxLength: buffer.count), count > 0 {
      data.append(buffer, count: count)
    }
    return data
  }
}

/// Keeps the session in memory instead of the Keychain.
final class InMemorySessionStorage: AuthLocalStorage {
  private let values = Mutex<[String: Data]>([:])

  func store(key: String, value: Data) throws { values.withLock { $0[key] = value } }
  func retrieve(key: String) throws -> Data? { values.withLock { $0[key] } }
  func remove(key: String) throws { _ = values.withLock { $0.removeValue(forKey: key) } }
}

/// The local stack's answer to a password or refresh-token grant for alex@kiwi.test, trimmed to
/// what the SDK reads.
func sessionResponse(expiresAt: Date = .now.addingTimeInterval(3600)) -> String {
  """
  {
    "access_token": "access-token", "token_type": "bearer", "expires_in": 3600,
    "expires_at": \(Int(expiresAt.timeIntervalSince1970)), "refresh_token": "refresh-token",
    "user": {
      "id": "11111111-1111-4111-8111-111111111111", "aud": "authenticated",
      "role": "authenticated", "email": "alex@kiwi.test",
      "app_metadata": {"provider": "email", "providers": ["email"]}, "user_metadata": {},
      "created_at": "2026-11-20T20:51:10.959317Z", "updated_at": "2026-11-21T12:52:17.617268Z",
      "is_anonymous": false
    }
  }
  """
}

/// The local stack's error body, as for a wrong password. The SDK asks for API version
/// 2024-01-01, which names the error in `code`.
func errorResponse(code: String?) -> String {
  let code = code.map { #""code": "\#($0)", "# } ?? ""
  return #"{\#(code)"message": "Recorded error"}"#
}
