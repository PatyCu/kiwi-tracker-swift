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
  // Covers: AUTH-001
  @Test func signsInWithTheEmailAndPassword() async throws {
    let sent = Mutex<(path: String?, grantType: String?, body: [String: String])?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
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

  // Covers: AUTH-004
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
    let backend = try StubSupabaseServer.backend { _, _ in
      (status, errorResponse(code: code))
    }

    await #expect(throws: expected) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  // Covers: AUTH-004
  @Test func mapsAFailedRequestToNetwork() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: SignInError.network) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  // Covers: AUTH-004
  @Test func wrapsOtherErrorsThrownByTheClient() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in (200, "not json") }

    await #expect(throws: SignInError.unknown) {
      try await SupabasePasswordAuth(backend: backend)
        .signIn(email: "alex@kiwi.test", password: "secret")
    }
  }

  // Covers: AUTH-009
  @Test func reportsTheStoredUserAndLaterChanges() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in (200, sessionResponse()) }
    let auth = SupabasePasswordAuth(backend: backend)
    var users = auth.signedInUsers().makeAsyncIterator()

    #expect(await users.next() == .some(nil))
    try await auth.signIn(email: "alex@kiwi.test", password: "secret")
    #expect(await users.next() == alex)
  }

  // Covers: AUTH-016
  @Test func signsOutOnThisDeviceOnly() async throws {
    let logout = Mutex<URLComponents?>(nil)
    let backend = try StubSupabaseServer.backend { request, _ in
      guard request.url?.path() == "/auth/v1/logout" else { return (200, sessionResponse()) }
      logout.withLock {
        $0 = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      }
      return (204, "")
    }
    let auth = SupabasePasswordAuth(backend: backend)
    var users = auth.signedInUsers().makeAsyncIterator()
    #expect(await users.next() == .some(nil))
    try await auth.signIn(email: "alex@kiwi.test", password: "secret")
    #expect(await users.next() == alex)

    try await auth.signOut()

    #expect(logout.withLock { $0 }?.queryItems == [URLQueryItem(name: "scope", value: "local")])
    #expect(await users.next() == .some(nil))
  }

  // Covers: AUTH-010
  @Test func waitsForTheRefreshOfAnExpiredStoredSession() async throws {
    let backend = try await installWithAnExpiredSession().launch { request, _ in
      #expect(grantType(of: request) == "refresh_token")
      return (200, sessionResponse())
    }
    var users = SupabasePasswordAuth(backend: backend).signedInUsers().makeAsyncIterator()

    #expect(await users.next() == alex)
  }

  // Covers: AUTH-011
  @Test func reportsNoUserWhenAnExpiredStoredSessionCannotRefresh() async throws {
    let backend = try await installWithAnExpiredSession().launch { _, _ in
      throw URLError(.notConnectedToInternet)
    }
    var users = SupabasePasswordAuth(backend: backend).signedInUsers().makeAsyncIterator()

    #expect(await users.next() == .some(nil))
  }

  /// An install whose previous launch signed in, leaving a session that has since expired.
  private func installWithAnExpiredSession() async throws -> Install {
    let install = try Install()
    let previousLaunch = try install.launch { _, _ in
      (200, sessionResponse(expiresAt: .now.addingTimeInterval(-60)))
    }
    try await SupabasePasswordAuth(backend: previousLaunch)
      .signIn(email: "alex@kiwi.test", password: "secret")
    return install
  }
}
