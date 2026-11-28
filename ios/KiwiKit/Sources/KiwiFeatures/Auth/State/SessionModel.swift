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
  private let photos: any PetPhotoCache

  init(auth: any PasswordAuth, photos: any PetPhotoCache) {
    self.auth = auth
    self.photos = photos
  }

  /// Ends the session on this device, then clears the Pet photos kept on it, so the next Account
  /// can't see them; `observe()` then switches to signed out. A failed sign-out keeps them.
  func signOut() async throws {
    try await auth.signOut()
    await photos.clear()
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
