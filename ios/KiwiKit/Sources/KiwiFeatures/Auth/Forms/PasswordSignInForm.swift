import Foundation
import KiwiDomain
import Observation

/// Email and password sign-in for existing accounts. On success the session switches the app over,
/// so the form stays "signing in" until it goes away.
@Observable final class PasswordSignInForm {
  var email = "" {
    didSet { clearError() }
  }
  var password = "" {
    didSet { clearError() }
  }
  private(set) var signingIn = false
  private(set) var error: String?

  private let auth: any PasswordAuth

  init(auth: any PasswordAuth) {
    self.auth = auth
  }

  func submit() async {
    if signingIn { return }
    let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    // Passwords are sent as typed: spaces can be part of them.
    if normalizedEmail.isEmpty || password.isEmpty {
      error = "Enter your email and password."
      return
    }
    signingIn = true
    error = nil
    do {
      try await auth.signIn(email: normalizedEmail, password: password)
    } catch {
      self.error = Self.message(for: error)
      signingIn = false
    }
  }

  private func clearError() {
    if error != nil { error = nil }
  }

  private static func message(for error: SignInError) -> String {
    switch error {
    case .invalidCredentials: "That email and password don’t match an account."
    case .emailNotConfirmed:
      "This account isn’t confirmed yet. Ask whoever set it up to confirm it."
    case .rateLimited: "Too many attempts. Wait a minute, then try again."
    case .network: "Can't reach Kiwi Tracker. Check your connection and try again."
    case .unknown: "Something went wrong. Try again."
    }
  }
}
