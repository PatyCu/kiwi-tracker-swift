import Foundation
import KiwiDesign
import KiwiDomain
import SwiftUI

/// The Pets tab: the Household's Pets as a row of selector cards, the first selected by default,
/// then the add card, above a placeholder for the selected Pet's overview. Selecting a card changes
/// the selection in place, without pushing a screen; its Edit button opens the Pet's details sheet.
/// With no Pets, the no-pets card.
struct PetsScreen: View {
  let household: Household
  let model: PetsModel
  /// The chosen Pet; `selectedPet(_:in:)` falls back to the first.
  @State private var selectedPetID: UUID?
  /// The details sheet open now, if any.
  @State private var details: DetailsRequest?

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
          ScrollView {
            NoPetsCard(
              description: "Add a pet to keep their profile, photo and health history together.",
              onAdd: { openDetails() }
            )
            .padding()
          }
        }
      }
    }
    .background(Palette.bg)
    .navigationTitle(petsTitle(for: household))
    .sheet(item: $details) { request in
      PetDetailsSheet(pets: model, householdID: household.id, editing: request.pet)
    }
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
              PetSelectorCard(
                pet: pet,
                isSelected: pet.id == selected.id,
                onSelect: { selectedPetID = pet.id },
                onEdit: { openDetails(keeping: selected, editing: pet) }
              )
            }
            AddPetCard { openDetails(keeping: selected) }
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

  /// Opens the details sheet. With `selected`, pins the Pet shown now, so a Pet added or renamed
  /// to sort before it doesn't take its place.
  private func openDetails(keeping selected: Pet? = nil, editing pet: Pet? = nil) {
    if let selected { selectedPetID = selected.id }
    details = DetailsRequest(pet: pet)
  }

  private func retry() {
    Task { await model.load() }
  }
}

/// Opens the details sheet for adding a Pet, or for editing `pet`.
private struct DetailsRequest: Identifiable {
  let id = UUID()
  let pet: Pet?
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
