#if DEBUG
  import Foundation
  import KiwiDomain
  import SwiftUI

  extension SignedInUser {
    nonisolated static let preview = SignedInUser(id: UUID(), email: "alex@kiwi.test")
  }

  extension View {
    /// Puts a session signed in as `user` in the environment, as `RootView` does.
    func previewSession(_ user: SignedInUser = .preview) -> some View {
      modifier(PreviewSessionModifier(user: user))
    }
  }

  private struct PreviewSessionModifier: ViewModifier {
    @State private var session: SessionModel

    init(user: SignedInUser) {
      _session = State(
        initialValue: SessionModel(
          auth: PreviewPasswordAuth(user: user), photos: PreviewPetPhotoStore()))
    }

    func body(content: Content) -> some View {
      content
        .environment(session)
        .task { await session.observe() }
    }
  }
#endif
