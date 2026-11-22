import KiwiDesign
import SwiftUI

/// The Settings tab, as the reference app's `SettingsScreen`. Appearance arrives with its own
/// feature, above Household.
struct SettingsScreen: View {
  let members: HouseholdMembersModel

  var body: some View {
    Form {
      HouseholdSection()
      MembersSection(model: members)
      AccountSection()
    }
    .scrollContentBackground(.hidden)
    .background(Palette.bg)
    .navigationTitle("Settings")
  }
}

#if DEBUG
  #Preview("Signed in") {
    NavigationStack {
      SettingsScreen(members: .preview())
    }
    .environment(\.household, .preview)
    .previewSession()
  }

  #Preview("Dark") {
    NavigationStack {
      SettingsScreen(members: .preview())
    }
    .environment(\.household, .preview)
    .previewSession()
    .preferredColorScheme(.dark)
  }
#endif
