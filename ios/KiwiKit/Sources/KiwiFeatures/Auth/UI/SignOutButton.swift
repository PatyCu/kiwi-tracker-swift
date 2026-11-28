import KiwiDesign
import SwiftUI

/// Sign out on this device as a standalone button, with "Could not sign out. Try again." under
/// it when that fails, for screens outside Settings such as the no-household screen. Expects the
/// `SessionModel` in the environment.
struct SignOutButton: View {
  @Environment(SessionModel.self) private var session
  @State private var model: SignOutModel

  init() {
    self.init(model: SignOutModel())
  }

  init(model: SignOutModel) {
    _model = State(initialValue: model)
  }

  var body: some View {
    VStack(spacing: 10) {
      Button("Sign out") {
        Task { await model.signOut(with: session.signOut) }
      }
      .font(.subheadline.bold())
      .foregroundStyle(Palette.coral)
      .disabled(model.signingOut)
      if let error = model.error {
        Text(error)
          .font(.subheadline)
          .foregroundStyle(Palette.coral)
      }
    }
    .onChange(of: model.error) { _, error in
      // Announced, as VoiceOver doesn't read text that appears on its own.
      if let error { AccessibilityNotification.Announcement(error).post() }
    }
  }
}

#if DEBUG
  #Preview("Ready") {
    SignOutButton().previewSession()
  }

  #Preview("Error") {
    let model = SignOutModel()
    SignOutButton(model: model)
      .previewSession()
      .task { await model.signOut { throw CancellationError() } }
  }
#endif
