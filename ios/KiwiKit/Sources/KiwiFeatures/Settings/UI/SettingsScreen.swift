import KiwiDesign
import SwiftUI

/// The Settings tab: appearance, the Household and its Members, then the Account.
struct SettingsScreen: View {
  let members: MembersModel

  var body: some View {
    Form {
      AppearanceSection()
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
