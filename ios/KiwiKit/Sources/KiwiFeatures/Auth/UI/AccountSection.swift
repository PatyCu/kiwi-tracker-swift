import KiwiDesign
import KiwiDomain
import SwiftUI

/// Who is signed in, and Sign out on this device, as the reference app's `AccountSection`.
struct AccountSection: View {
  @Environment(SessionModel.self) private var session
  @State private var model: SignOutModel

  init() {
    self.init(model: SignOutModel())
  }

  init(model: SignOutModel) {
    _model = State(initialValue: model)
  }

  var body: some View {
    if case .signedIn(let user) = session.state {
      Section {
        LabeledContent("Signed in as", value: user.email)
        Button(role: .destructive) {
          Task { await model.signOut(with: session.signOut) }
        } label: {
          Text(model.signingOut ? "Signing out…" : "Sign out")
            .foregroundStyle(Palette.coral)
        }
        .disabled(model.signingOut)
      } header: {
        Text("Account")
      } footer: {
        if let error = model.error {
          Text(error).foregroundStyle(Palette.coral)
        }
      }
      .onChange(of: model.error) { _, error in
        // The reference marks the error as an alert, which screen readers announce.
        if let error { AccessibilityNotification.Announcement(error).post() }
      }
    }
  }
}

#if DEBUG
  private func previewForm(_ model: SignOutModel = SignOutModel()) -> some View {
    Form { AccountSection(model: model) }
      .scrollContentBackground(.hidden)
      .background(Palette.bg)
      .previewSession()
  }

  #Preview("Signed in") {
    previewForm()
  }

  #Preview("Signing out") {
    let model = SignOutModel()
    previewForm(model).task {
      await model.signOut { try await Task.sleep(for: .seconds(3600)) }
    }
  }

  #Preview("Error") {
    let model = SignOutModel()
    previewForm(model).task {
      await model.signOut { throw CancellationError() }
    }
  }

  #Preview("Error, dark") {
    let model = SignOutModel()
    previewForm(model)
      .task { await model.signOut { throw CancellationError() } }
      .preferredColorScheme(.dark)
  }
#endif
