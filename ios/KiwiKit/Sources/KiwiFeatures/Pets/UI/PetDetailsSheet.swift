import Foundation
import KiwiDesign
import KiwiDomain
import PhotosUI
import SwiftUI

/// Adds a Pet or edits its details: a photo from the library, name, species, breed and an optional
/// date of birth, with Cancel and Add or Save. While saving, the confirm button shows a spinner and
/// the sheet can't be dismissed; a failed save keeps it open with an alert. Cancel or swiping down
/// discards the changes, a picked photo too, without asking. Builds its own form, so the tabs that
/// present it only hand in the Pets and the Household.
struct PetDetailsSheet: View {
  @State private var form: PetDetailsForm
  /// The library item just picked, until the form has prepared it.
  @State private var pickerItem: PhotosPickerItem?
  @Environment(\.dismiss) private var dismiss
  @FocusState private var nameFocused: Bool
  private let onPhotoNotSaved: (String) -> Void

  /// Adds a Pet to the Household with `householdID`, or, with `pet`, edits that Pet. Once the
  /// sheet has closed after saving the details but not the photo, calls `onPhotoNotSaved` with the
  /// Pet's name, so the presenting screen shows `photoNotSavedAlert`.
  init(
    pets: PetsModel, householdID: UUID, editing pet: Pet? = nil,
    onPhotoNotSaved: @escaping (String) -> Void
  ) {
    self.init(
      form: PetDetailsForm(pets: pets, householdID: householdID, editing: pet),
      onPhotoNotSaved: onPhotoNotSaved)
  }

  fileprivate init(form: PetDetailsForm, onPhotoNotSaved: @escaping (String) -> Void = { _ in }) {
    _form = State(initialValue: form)
    self.onPhotoNotSaved = onPhotoNotSaved
  }

  var body: some View {
    @Bindable var form = form
    NavigationStack {
      Form {
        Section {
          PetPhotoButton(photo: form.shownPhoto, selection: $pickerItem)
        }
        .listRowBackground(Color.clear)
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
    .task { await form.loadStoredPhoto() }
    .onChange(of: form.isOpen) { _, isOpen in
      if !isOpen { dismiss() }
    }
    .onChange(of: pickerItem) { _, item in
      guard let item else { return }
      Task {
        let data = (try? await item.loadTransferable(type: Data.self)) ?? nil
        await form.pickPhoto(data)
        // Cleared, so picking the same photo again is seen as a new pick.
        pickerItem = nil
      }
    }
    .onDisappear {
      if let name = form.photoNotSavedFor { onPhotoNotSaved(name) }
    }
    .alert(
      failureTitle,
      isPresented: Binding(
        get: { form.failure != nil },
        set: { if !$0 { form.failure = nil } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      if form.failure == .photoNotSelected {
        Text("The photo library could not be opened. Please try again.")
      } else {
        Text("The pet could not be confirmed as saved. Reopen the app before trying again.")
      }
    }
  }

  private var failureTitle: String {
    switch form.failure {
    case .photoNotSelected: "Photo not selected"
    case .notUpdated: "Pet not updated"
    case .notAdded, nil: "Pet not added"
    }
  }
}

/// The sheet's first row: the photo shown, or a camera placeholder, with "Add photo" or "Change
/// photo" under it. Opens the system photo picker, filtered to images, which runs outside the app,
/// so it needs no library permission and the app sees only the photo chosen.
private struct PetPhotoButton: View {
  let photo: Data?
  @Binding var selection: PhotosPickerItem?

  var body: some View {
    let label = photo == nil ? "Add photo" : "Change photo"
    PhotosPicker(selection: $selection, matching: .images) {
      VStack(spacing: 8) {
        Group {
          if let photo, let image = UIImage(data: photo) {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
          } else {
            Image(systemName: "camera")
              .font(.title)
              .foregroundStyle(Palette.kiwi)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Palette.surface2)
          }
        }
        .frame(width: 92, height: 92)
        .clipShape(.rect(cornerRadius: 28))
        Text(label)
          .font(.footnote.bold())
          .foregroundStyle(Palette.kiwi)
      }
      .frame(maxWidth: .infinity)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(label)
    .accessibilityAddTraits(.isButton)
  }
}

extension View {
  /// The alert for a Pet whose details saved but whose photo didn't, shown while `petName` is set.
  func photoNotSavedAlert(_ petName: Binding<String?>) -> some View {
    alert(
      "Photo not saved",
      isPresented: Binding(
        get: { petName.wrappedValue != nil },
        set: { if !$0 { petName.wrappedValue = nil } }
      ),
      presenting: petName.wrappedValue
    ) { _ in
      Button("OK", role: .cancel) {}
    } message: { name in
      Text("\(name) was saved, but the photo could not be uploaded. Edit the pet to try again.")
    }
  }
}

#if DEBUG
  private func previewSheet(
    editing pet: Pet? = nil,
    save: PreviewPetStore.SaveOutcome = .saves,
    startSaving: Bool = false,
    picking: Bool = false
  ) -> some View {
    let form = PetDetailsForm(
      pets: .preview(save: save), householdID: Household.preview.id, editing: pet)
    if picking {
      Task { await form.pickPhoto(previewPhoto()) }
    }
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

  #Preview("Editing, stored photo") {
    previewSheet(editing: Pet.previews[0])
  }

  #Preview("Editing, no photo") {
    previewSheet(editing: Pet.previews[1])
  }

  #Preview("Adding, photo picked") {
    previewSheet(picking: true)
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

  #Preview("Editing, stored photo, dark") {
    previewSheet(editing: Pet.previews[0]).preferredColorScheme(.dark)
  }

  #Preview("Adding, photo picked, dark") {
    previewSheet(picking: true).preferredColorScheme(.dark)
  }
#endif
