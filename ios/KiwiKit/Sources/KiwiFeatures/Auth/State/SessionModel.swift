import KiwiDomain
import Observation

/// Who is signed in on this device.
@Observable final class SessionModel {
  enum State: Equatable {
    /// The stored session is still being read.
    case loading
    case signedOut
    case signedIn(SignedInUser)
  }

  private(set) var state = State.loading
  private let auth: any PasswordAuth

  init(auth: any PasswordAuth) {
    self.auth = auth
  }

  /// Ends the session on this device; `observe()` then switches to signed out.
  func signOut() async throws {
    try await auth.signOut()
  }

  /// Follows sign-in and sign-out until the calling task is cancelled.
  func observe() async {
    for await user in auth.signedInUsers() {
      let next = user.map(State.signedIn) ?? .signedOut
      // Token refreshes report the same user again; not assigning avoids re-rendering the app.
      if next != state { state = next }
    }
  }
}
