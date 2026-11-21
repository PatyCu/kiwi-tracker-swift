import KiwiDesign
import SwiftUI

/// Shown when the app can't offer sign-in at all, such as missing Supabase settings.
struct SignInUnavailableScreen: View {
  let message: String

  var body: some View {
    VStack(spacing: 10) {
      Text("Sign-in is not available")
        .font(.title2.bold())
        .foregroundStyle(Palette.text)
        .accessibilityAddTraits(.isHeader)
      Text(message)
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
        .frame(maxWidth: 420)
    }
    .multilineTextAlignment(.center)
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Palette.bg)
  }
}

#if DEBUG
  #Preview("Light") {
    SignInUnavailableScreen(message: PreviewPasswordAuth.setupError)
  }

  #Preview("Dark") {
    SignInUnavailableScreen(message: PreviewPasswordAuth.setupError)
      .preferredColorScheme(.dark)
  }
#endif
