import Observation

/// The Sign out button's state. On success the session switches the app to sign-in, so it stays
/// "signing out" until the section goes away.
@Observable final class SignOutModel {
  private(set) var signingOut = false
  private(set) var error: String?

  func signOut(with endSession: () async throws -> Void) async {
    if signingOut { return }
    signingOut = true
    error = nil
    do {
      try await endSession()
    } catch {
      self.error = "Could not sign out. Try again."
      signingOut = false
    }
  }
}
