import Foundation
import KiwiDesign
import KiwiDomain
import SwiftUI

/// Adds a Pet or edits its details: name, species, breed and an optional date of birth, with Cancel
/// and Add or Save. While saving, the confirm button shows a spinner and the sheet can't be
/// dismissed; a failed save keeps it open with an alert. Cancel or swiping down discards the
/// changes without asking. Builds its own form, so the tabs that present it only hand in the Pets
/// and the Household.
struct PetDetailsSheet: View {
  @State private var form: PetDetailsForm
  @Environment(\.dismiss) private var dismiss
  @FocusState private var nameFocused: Bool

  /// Adds a Pet to the Household with `householdID`, or, with `pet`, edits that Pet.
  init(pets: PetsModel, householdID: UUID, editing pet: Pet? = nil) {
    self.init(form: PetDetailsForm(pets: pets, householdID: householdID, editing: pet))
  }

  fileprivate init(form: PetDetailsForm) {
    _form = State(initialValue: form)
  }

  var body: some View {
    @Bindable var form = form
    NavigationStack {
      Form {
        Section {
          TextField("Name", text: $form.name, prompt: Text("e.g. Miso"))
            .focused($nameFocused)
            .submitLabel(.done)
        } header: {
          Text("Name")
        }
        Section {
          PetSpeciesPicker(species: $form.species)
        } header: {
          Text("Species")
        }
        Section {
          TextField("Breed", text: $form.breed, prompt: Text("e.g. European shorthair"))
        } header: {
          Text("Breed")
        }
        Section {
          PetBirthDateField(birthDate: $form.birthDate)
        }
      }
      .disabled(form.isSaving)
      .scrollContentBackground(.hidden)
      .background(Palette.bg)
      .navigationTitle(form.editing == nil ? "Add a pet" : "Edit pet")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
            .disabled(form.isSaving)
        }
        ToolbarItem(placement: .confirmationAction) {
          if form.isSaving {
            ProgressView()
          } else {
            Button(form.editing == nil ? "Add" : "Save") {
              Task { await form.save() }
            }
            .disabled(!form.canSave)
          }
        }
      }
    }
    .tint(Palette.kiwi)
    .interactiveDismissDisabled(form.isSaving)
    .onAppear { nameFocused = true }
    .onChange(of: form.isOpen) { _, isOpen in
      if !isOpen { dismiss() }
    }
    .alert(
      form.failure == .notUpdated ? "Pet not updated" : "Pet not added",
      isPresented: Binding(
        get: { form.failure != nil },
        set: { if !$0 { form.failure = nil } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("The pet could not be confirmed as saved. Reopen the app before trying again.")
    }
  }
}

#if DEBUG
  private func previewSheet(
    editing pet: Pet? = nil,
    save: PreviewPetStore.SaveOutcome = .saves,
    startSaving: Bool = false
  ) -> some View {
    let form = PetDetailsForm(
      pets: .preview(save: save), householdID: Household.preview.id, editing: pet)
    if startSaving {
      form.name = "Miso"
      Task {
        // Waits for the preview Pets, which start loading as the app does at sign-in.
        try? await Task.sleep(for: .milliseconds(100))
        await form.save()
      }
    }
    return Color.clear.sheet(isPresented: .constant(true)) { PetDetailsSheet(form: form) }
  }

  #Preview("Adding") {
    previewSheet()
  }

  #Preview("Editing") {
    previewSheet(editing: Pet.previews[0])
  }

  #Preview("Saving") {
    previewSheet(save: .staysSaving, startSaving: true)
  }

  #Preview("Save failed") {
    previewSheet(save: .fails, startSaving: true)
  }

  #Preview("Adding, dark") {
    previewSheet().preferredColorScheme(.dark)
  }

  #Preview("Editing, dark") {
    previewSheet(editing: Pet.previews[0]).preferredColorScheme(.dark)
  }
#endif
