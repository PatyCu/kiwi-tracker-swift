import KiwiDesign
import SwiftUI

/// The Settings tab, as the reference app's `SettingsScreen`. Appearance arrives with its own
/// feature, above Household.
struct SettingsScreen: View {
  var body: some View {
    Form {
      HouseholdSection()
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
      .environment(\.household, .preview)
      .previewSession()
  }

  #Preview("Dark") {
    NavigationStack { SettingsScreen() }
      .environment(\.household, .preview)
      .previewSession()
      .preferredColorScheme(.dark)
  }
#endif
