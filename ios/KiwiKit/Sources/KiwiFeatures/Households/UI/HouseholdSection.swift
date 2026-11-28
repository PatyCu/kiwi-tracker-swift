import KiwiDesign
import KiwiDomain
import SwiftUI

/// The signed-in Account's Household in Settings, its alias labelled "Alias" as in the glossary.
/// The Members follow in `MembersSection`.
struct HouseholdSection: View {
  @Environment(\.household) private var household

  var body: some View {
    // Always set inside the tabs; see `EnvironmentValues.household`.
    if let household {
      Section("Household") {
        LabeledContent("Alias", value: household.alias)
      }
    }
  }
}

#if DEBUG
  private func previewForm() -> some View {
    Form { HouseholdSection() }
      .scrollContentBackground(.hidden)
      .background(Palette.bg)
      .environment(\.household, .preview)
  }

  #Preview("Light") {
    previewForm()
  }

  #Preview("Dark") {
    previewForm().preferredColorScheme(.dark)
  }
#endif
