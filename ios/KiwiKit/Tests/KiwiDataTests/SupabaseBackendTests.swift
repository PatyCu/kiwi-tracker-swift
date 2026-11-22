import Foundation
import KiwiDomain
import Testing

@testable import KiwiData

private let alex = SignedInUser(
  id: UUID(uuidString: "11111111-1111-4111-8111-111111111111") ?? UUID(),
  email: "alex@kiwi.test"
)

private func firstUser(after backend: SupabaseBackend) async -> SignedInUser?? {
  var users = SupabasePasswordAuth(backend: backend).signedInUsers().makeAsyncIterator()
  return await users.next()
}

private func signIn(on install: Install) async throws {
  try await SupabasePasswordAuth(backend: install.launch())
    .signIn(email: "alex@kiwi.test", password: "secret")
}

@Suite struct SupabaseBackendTests {
  @Test func clearsTheStoredSessionOnTheFirstLaunchAfterAnInstall() async throws {
    let install = try Install()
    try await signIn(on: install)

    let reinstall = try install.reinstalled()

    #expect(await firstUser(after: try reinstall.launch()) == .some(nil))
    #expect(reinstall.storage.isEmpty)
  }

  @Test func restoresTheStoredSessionOnLaterLaunches() async throws {
    let install = try Install()
    try await signIn(on: install)

    #expect(await firstUser(after: try install.launch()) == alex)
  }

  @Test func retriesOnTheNextLaunchWhenRemovingTheSessionFails() async throws {
    let install = try Install()
    try await signIn(on: install)
    let reinstall = try install.reinstalled()

    reinstall.storage.failsToRemove = true
    #expect(await firstUser(after: try reinstall.launch()) == alex)
    reinstall.storage.failsToRemove = false

    #expect(await firstUser(after: try reinstall.launch()) == .some(nil))
    #expect(reinstall.storage.isEmpty)
  }
}
