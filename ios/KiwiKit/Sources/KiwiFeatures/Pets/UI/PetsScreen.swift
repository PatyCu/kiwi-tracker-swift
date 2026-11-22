import Foundation
import KiwiDesign
import KiwiDomain
import SwiftUI

/// The Pets tab, as the reference app's `PetsScreen`: the Household's Pets as a row of selector
/// cards, the first selected by default, above a placeholder for the selected Pet's overview.
/// Selecting a card changes the selection in place, without pushing a screen.
struct PetsScreen: View {
  let household: Household
  let model: PetsModel
  /// The chosen Pet; `selectedPet(_:in:)` falls back to the first.
  @State private var selectedPetID: UUID?

  var body: some View {
    Group {
      switch model.state {
      case .loading:
        ScrollView { LoadingView().padding(.horizontal) }
      case .failed:
        ScrollView { LoadErrorView(onRetry: retry).padding(.horizontal) }
      case .ready(let pets):
        if let selected = selectedPet(selectedPetID, in: pets) {
          selector(pets: pets, selected: selected)
        } else {
          // The no-pets card replaces this with KIW-84.
          PlaceholderScreen(tab: .pets, navigationTitle: petsTitle(for: household))
        }
      }
    }
    .background(Palette.bg)
    .navigationTitle(petsTitle(for: household))
  }

  private func selector(pets: [Pet], selected: Pet) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Choose the pet you want to manage.")
          .font(.caption)
          .foregroundStyle(Palette.muted)
          .padding(.bottom, 10)
        ScrollView(.horizontal) {
          HStack(spacing: 10) {
            ForEach(pets) { pet in
              PetSelectorCard(pet: pet, isSelected: pet.id == selected.id) {
                selectedPetID = pet.id
              }
            }
          }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .padding(.bottom, 24)
        // The overview replaces this with KIW-26.
        PlaceholderCard(
          title: "Overview",
          description: "This screen arrives in a later migration phase.",
          systemImage: "pawprint"
        )
      }
      .padding()
    }
  }

  private func retry() {
    Task { await model.load() }
  }
}

#if DEBUG
  private func previewScreen(_ outcome: PreviewPetStore.Outcome) -> some View {
    NavigationStack { PetsScreen(household: .preview, model: .preview(outcome)) }
  }

  #Preview("Loaded") {
    previewScreen(.loads(Pet.previews))
  }

  #Preview("No pets") {
    previewScreen(.loads([]))
  }

  #Preview("Loading") {
    previewScreen(.staysLoading)
  }

  #Preview("Error") {
    previewScreen(.fails)
  }

  #Preview("Loaded, dark") {
    previewScreen(.loads(Pet.previews)).preferredColorScheme(.dark)
  }

  #Preview("No pets, dark") {
    previewScreen(.loads([])).preferredColorScheme(.dark)
  }

  #Preview("Loading, dark") {
    previewScreen(.staysLoading).preferredColorScheme(.dark)
  }

  #Preview("Error, dark") {
    previewScreen(.fails).preferredColorScheme(.dark)
  }
#endif
