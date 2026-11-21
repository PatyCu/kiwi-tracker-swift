import KiwiDesign
import KiwiDomain
import SwiftUI

/// The app's root: sign-in until someone is signed in, then the tabs. Shows why sign-in is
/// unavailable when the app can't set it up. The order follows the reference app's `RootStack`.
public struct AppRoot: View {
  private enum Setup {
    case ready(any PasswordAuth)
    case unavailable(String)
  }

  private let setup: Setup

  public init(auth: any PasswordAuth) {
    setup = .ready(auth)
  }

  /// For a build that can't offer sign-in; `message` says why.
  public init(signInUnavailable message: String) {
    setup = .unavailable(message)
  }

  public var body: some View {
    switch setup {
    case .ready(let auth): SessionRoot(auth: auth)
    case .unavailable(let message): SignInUnavailableScreen(message: message)
    }
  }
}

/// Switches on who is signed in.
private struct SessionRoot: View {
  let auth: any PasswordAuth
  @State private var session: SessionModel

  init(auth: any PasswordAuth) {
    self.auth = auth
    _session = State(initialValue: SessionModel(auth: auth))
  }

  var body: some View {
    Group {
      switch session.state {
      case .loading:
        // Reading the stored session takes a moment; a blank screen avoids flashing sign-in.
        Palette.bg.ignoresSafeArea()
      case .signedOut:
        SignInScreen(auth: auth)
      case .signedIn:
        AppShell()
      }
    }
    .task { await session.observe() }
  }
}

#if DEBUG
  #Preview("Signed out") {
    AppRoot(auth: PreviewPasswordAuth())
  }

  #Preview("Signed in") {
    AppRoot(
      auth: PreviewPasswordAuth(user: SignedInUser(id: UUID(), email: "alex@kiwi.test"))
    )
  }

  #Preview("Sign-in unavailable") {
    AppRoot(signInUnavailable: PreviewPasswordAuth.setupError)
  }
#endif
