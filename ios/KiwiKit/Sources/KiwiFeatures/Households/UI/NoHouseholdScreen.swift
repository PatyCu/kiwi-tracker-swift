import KiwiDesign
import SwiftUI

/// Shown instead of the app when the signed-in Account isn't in a Household, as the reference
/// app's `NoHouseholdScreen`. Every Account should have one, so this points at a setup mistake
/// rather than showing an empty app. The app root hands in the Account's email, Check again and
/// the Sign out control, so this folder doesn't depend on Auth.
struct NoHouseholdScreen<SignOut: View>: View {
  private let email: String?
  private let onCheckAgain: () -> Void
  private let signOut: SignOut

  init(
    email: String?,
    onCheckAgain: @escaping () -> Void,
    @ViewBuilder signOut: () -> SignOut
  ) {
    self.email = email
    self.onCheckAgain = onCheckAgain
    self.signOut = signOut()
  }

  var body: some View {
    VStack(spacing: 10) {
      Text("This account isn't in a household yet")
        .font(.title2.bold())
        .foregroundStyle(Palette.text)
        .accessibilityAddTraits(.isHeader)
      Text(noHouseholdMessage(email: email))
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
        .frame(maxWidth: 420)
      VStack(spacing: 16) {
        Button("Check again", action: onCheckAgain)
          .font(.subheadline.weight(.heavy))
          .foregroundStyle(Palette.ink)
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.roundedRectangle(radius: 14))
          .controlSize(.large)
          .tint(Palette.kiwi)
        signOut
      }
      .padding(.top, 12)
    }
    .multilineTextAlignment(.center)
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Palette.bg)
  }
}

/// The no-household screen's explanation, naming the Account when its email is known.
func noHouseholdMessage(email: String?) -> String {
  let who = email.flatMap { $0.isEmpty ? nil : "\($0) needs" } ?? "Your account needs"
  return "\(who) to be added to a household before you can use Kiwi Tracker. "
    + "Ask whoever set up your account, then check again."
}

#if DEBUG
  private func previewScreen() -> some View {
    NoHouseholdScreen(email: "alex@kiwi.test", onCheckAgain: {}) {
      Button("Sign out") {}
        .font(.subheadline.bold())
        .foregroundStyle(Palette.coral)
    }
  }

  #Preview("Light") {
    previewScreen()
  }

  #Preview("Dark") {
    previewScreen().preferredColorScheme(.dark)
  }
#endif
