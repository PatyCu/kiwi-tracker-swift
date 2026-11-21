import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

private let alex = SignedInUser(
  id: UUID(uuidString: "11111111-1111-4111-8111-111111111111") ?? UUID(),
  email: "alex@kiwi.test"
)

private func grantType(of request: URLRequest) -> String? {
  request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
    .queryItems?.first { $0.name == "grant_type" }?.value
}

@Suite struct SupabasePasswordAuthTests {
  @Test func signsInWithTheEmailAndPassword() async throws {
    let sent = Mutex<(path: String?, grantType: String?, body: [String: String])?>(nil)
    let backend = try RecordedAuthServer.backend { request, body in
      let fields = (try? JSONDecoder().decode([String: String].self, from: body)) ?? [:]
      sent.withLock { $0 = (request.url?.path(), grantType(of: request), fields) }
      return (200, sessionResponse())
    }

    try await SupabasePasswordAuth(backend: backend)
      .signIn(email: "alex@kiwi.test", password: "secret")

    let request = try #require(sent.withLock { $0 })
    #expect(request.path == "/auth/v1/token")
    #expect(request.grantType == "password")
    #expect(request.body["email"] == "alex@kiwi.test")
    #expect(request.body["password"] == "secret")
  }

  @Test(arguments: [
    (400, "invalid_credentials" as String?, SignInError.invalidCredentials),
    (400, "email_not_confirmed", .emailNotConfirmed),
    (429, nil, .rateLimited),
    (503, nil, .network),
    (500, "unexpected_failure", .unknown),
  ])
  func mapsTheErrorReturnedBySupabase(status: Int, code: String?, expected: SignInError)
    async throws
  {
    let backend = try RecordedAuthServer.backend { _, _ in
      (status, errorResponse(code: code))
    }

    await #expect(throws: expected) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  @Test func mapsAFailedRequestToNetwork() async throws {
    let backend = try RecordedAuthServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: SignInError.network) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  @Test func wrapsOtherErrorsThrownByTheClient() async throws {
    let backend = try RecordedAuthServer.backend { _, _ in (200, "not json") }

    await #expect(throws: SignInError.unknown) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  @Test func reportsTheStoredUserAndLaterChanges() async throws {
    let backend = try RecordedAuthServer.backend { _, _ in (200, sessionResponse()) }
    let auth = SupabasePasswordAuth(backend: backend)
    var users = auth.signedInUsers().makeAsyncIterator()

    #expect(await users.next() == .some(nil))
    try await auth.signIn(email: "alex@kiwi.test", password: "secret")
    #expect(await users.next() == alex)
  }

  @Test func waitsForTheRefreshOfAnExpiredStoredSession() async throws {
    let (host, storage) = try await storeExpiredSession()
    let backend = try RecordedAuthServer.backend(host: host, storage: storage) { request, _ in
      #expect(grantType(of: request) == "refresh_token")
      return (200, sessionResponse())
    }
    var users = SupabasePasswordAuth(backend: backend).signedInUsers().makeAsyncIterator()

    #expect(await users.next() == alex)
  }

  @Test func reportsNoUserWhenAnExpiredStoredSessionCannotRefresh() async throws {
    let (host, storage) = try await storeExpiredSession()
    let backend = try RecordedAuthServer.backend(host: host, storage: storage) { _, _ in
      throw URLError(.notConnectedToInternet)
    }
    var users = SupabasePasswordAuth(backend: backend).signedInUsers().makeAsyncIterator()

    #expect(await users.next() == .some(nil))
  }

  /// Signs in as a previous launch would have, leaving a session that has since expired.
  private func storeExpiredSession() async throws -> (String, InMemorySessionStorage) {
    let host = RecordedAuthServer.newHost()
    let storage = InMemorySessionStorage()
    let previousLaunch = try RecordedAuthServer.backend(host: host, storage: storage) { _, _ in
      (200, sessionResponse(expiresAt: .now.addingTimeInterval(-60)))
    }
    try await SupabasePasswordAuth(backend: previousLaunch)
      .signIn(email: "alex@kiwi.test", password: "secret")
    return (host, storage)
  }
}
