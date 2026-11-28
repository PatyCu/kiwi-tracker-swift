import Foundation
import Supabase
import Synchronization

@testable import KiwiData

/// Answers a backend's requests with hand-written Supabase responses. Each test uses its own
/// host, so tests running in parallel don't share answers.
final class StubSupabaseServer: URLProtocol, @unchecked Sendable {
  typealias Answer = @Sendable (URLRequest, Data) throws -> (status: Int, body: String)

  private static let answers = Mutex<[String: Answer]>([:])

  /// A backend whose requests `answer` handles, keeping its session in `storage` and its
  /// launch flag in `installDefaults`. The SDK keys the stored session by host.
  static func backend(
    host: String = newHost(),
    storage: some AuthLocalStorage = InMemorySessionStorage(),
    installDefaults: UserDefaults? = nil,
    answer: @escaping Answer
  ) throws -> SupabaseBackend {
    answers.withLock { $0[host] = answer }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubSupabaseServer.self]
    return SupabaseBackend(
      config: try SupabaseConfig(url: "http://\(host)", publishableKey: "sb_publishable_test"),
      sessionStorage: storage,
      installDefaults: try installDefaults ?? Install.newDefaults(),
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

/// One install of the app, launched against the stub server: the Keychain (`storage`)
/// outlives the install, its UserDefaults don't. A later launch of the same install reuses all
/// three.
struct Install {
  let host: String
  let storage: InMemorySessionStorage
  let defaults: UserDefaults

  init(storage: InMemorySessionStorage = InMemorySessionStorage()) throws {
    self.init(
      host: StubSupabaseServer.newHost(), storage: storage, defaults: try Self.newDefaults())
  }

  private init(host: String, storage: InMemorySessionStorage, defaults: UserDefaults) {
    self.host = host
    self.storage = storage
    self.defaults = defaults
  }

  func launch(
    answer: @escaping StubSupabaseServer.Answer = { _, _ in (200, sessionResponse()) }
  )
    throws -> SupabaseBackend
  {
    try StubSupabaseServer.backend(
      host: host, storage: storage, installDefaults: defaults, answer: answer)
  }

  /// The app deleted and installed again on the same device.
  func reinstalled() throws -> Install {
    Install(host: host, storage: storage, defaults: try Self.newDefaults())
  }

  /// A UserDefaults suite of its own, as iOS deletes the app's defaults with the app.
  static func newDefaults() throws -> UserDefaults {
    guard let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)") else {
      throw URLError(.cannotCreateFile)
    }
    return defaults
  }
}

/// Keeps the session in memory instead of the Keychain. Like `KeychainSessionStorage`, reading or
/// removing a missing session isn't an error.
final class InMemorySessionStorage: AuthLocalStorage {
  private let values = Mutex<[String: Data]>([:])
  private let removalFails = Mutex(false)

  /// Makes `remove` throw, as a Keychain error would.
  var failsToRemove: Bool {
    get { removalFails.withLock { $0 } }
    set { removalFails.withLock { $0 = newValue } }
  }
  var isEmpty: Bool { values.withLock { $0.isEmpty } }

  func store(key: String, value: Data) throws { values.withLock { $0[key] = value } }
  func retrieve(key: String) throws -> Data? { values.withLock { $0[key] } }
  func remove(key: String) throws {
    if failsToRemove { throw URLError(.cannotRemoveFile) }
    _ = values.withLock { $0.removeValue(forKey: key) }
  }
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
  return #"{\#(code)"message": "Stub error"}"#
}
