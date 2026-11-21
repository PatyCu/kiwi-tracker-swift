import Foundation

/// The account signed in on this device.
public struct SignedInUser: Equatable, Sendable {
  public let id: UUID
  public let email: String

  public init(id: UUID, email: String) {
    self.id = id
    self.email = email
  }
}

/// Why signing in failed.
public enum SignInError: Error, Equatable, Sendable {
  /// Supabase reports an unknown email and a wrong password the same way.
  case invalidCredentials
  case emailNotConfirmed
  case rateLimited
  case network
  case unknown
}

/// Email and password sign-in for existing accounts; accounts are created in the Supabase
/// dashboard, never from the app.
public protocol PasswordAuth: Sendable {
  /// Signs in and stores the session on the device; `signedInUsers()` then reports the user.
  func signIn(email: String, password: String) async throws(SignInError)

  /// The stored user (or `nil`) right away, then the user after every sign-in, sign-out and
  /// token refresh. Ending the iteration unsubscribes.
  func signedInUsers() -> AsyncStream<SignedInUser?>
}
