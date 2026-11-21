import KiwiDesign
import SwiftUI

/// The Settings tab, as the reference app's `SettingsScreen`. Appearance and the household
/// arrive with their own features.
struct SettingsScreen: View {
  var body: some View {
    Form {
      AccountSection()
    }
    .scrollContentBackground(.hidden)
    .background(Palette.bg)
    .navigationTitle("Settings")
  }
}

#if DEBUG
  #Preview("Signed in") {
    NavigationStack { SettingsScreen() }
      .previewSession()
  }

  #Preview("Dark") {
    NavigationStack { SettingsScreen() }
      .previewSession()
      .preferredColorScheme(.dark)
  }
#endif
