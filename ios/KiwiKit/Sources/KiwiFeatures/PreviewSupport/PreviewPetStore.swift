#if DEBUG
  import Foundation
  import KiwiDesign
  import KiwiDomain
  import SwiftUI

  extension Pet {
    /// The preview Household's Pets, sorted by name, as the seeded shared Household's. Kiwi
    /// has a photo; Luna shows the paw.
    nonisolated static let previews = [
      Pet(
        id: UUID(), name: "Kiwi", species: .cat, breed: "European shorthair",
        birthDate: BirthDate(year: 2021, month: 4, day: 12), photoPath: "kiwi/preview.jpg"),
      Pet(id: UUID(), name: "Luna", species: .dog),
    ]
  }

  /// The Pets for previews: loads them, fails, or never finishes. Saves answer after a moment
  /// with the Pet as sent, fail, or never finish, as `save` says.
  nonisolated struct PreviewPetStore: PetStore {
    enum Outcome {
      case loads([Pet])
      case fails
      case staysLoading
    }

    enum SaveOutcome {
      case saves
      case fails
      case staysSaving
    }

    var outcome = Outcome.loads(Pet.previews)
    var save = SaveOutcome.saves

    func loadPets() async throws(PetStoreError) -> [Pet] {
      switch outcome {
      case .loads(let pets): return pets
      case .fails: throw .couldNotLoad
      case .staysLoading:
        try? await Task.sleep(for: .seconds(3600))
        return []
      }
    }

    func addPet(_ details: PetDetails, to householdID: UUID) async throws(PetStoreError) -> Pet {
      try await stored(details, id: UUID())
    }

    func updatePet(_ id: UUID, _ details: PetDetails) async throws(PetStoreError) -> Pet {
      try await stored(details, id: id)
    }

    func setPhotoPath(_ path: String, of id: UUID) async throws(PetStoreError) -> Pet {
      let pet = Pet.previews.first { $0.id == id }
      return Pet(
        id: id, name: pet?.name ?? "Miso", species: pet?.species ?? .cat, breed: pet?.breed,
        birthDate: pet?.birthDate, photoPath: path)
    }

    private func stored(_ details: PetDetails, id: UUID) async throws(PetStoreError) -> Pet {
      try? await Task.sleep(for: .seconds(save == .staysSaving ? 3600 : 1))
      if save == .fails { throw .couldNotSave }
      return Pet(
        id: id, name: details.name, species: details.species, breed: details.breed,
        birthDate: details.birthDate,
        photoPath: Pet.previews.first { $0.id == id }?.photoPath)
    }
  }

  /// Photo storage for previews: every path answers with the same drawn photo, and uploads
  /// succeed.
  nonisolated struct PreviewPetPhotoStore: PetPhotoCache {
    func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String {
      "\(petID)/\(UUID()).jpg"
    }

    func remove(_ path: String) async throws(PetPhotoStoreError) {}

    func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data {
      await previewPhoto()
    }

    func clear() async {}
  }

  /// A drawn stand-in for a Pet's photo, as a JPEG.
  @MainActor func previewPhoto() -> Data {
    let renderer = ImageRenderer(
      content: Image(systemName: "cat.fill")
        .font(.system(size: 120))
        .foregroundStyle(Palette.surface)
        .frame(width: 256, height: 256)
        .background(Palette.kiwi)
    )
    return renderer.uiImage?.jpegData(compressionQuality: 0.72) ?? Data()
  }

  extension PetsModel {
    /// Pets for previews, already loading from `PreviewPetStore`, as the app starts the load at
    /// sign-in.
    static func preview(
      _ outcome: PreviewPetStore.Outcome = .loads(Pet.previews),
      save: PreviewPetStore.SaveOutcome = .saves
    ) -> PetsModel {
      let model = PetsModel(
        store: PreviewPetStore(outcome: outcome, save: save), photos: PreviewPetPhotoStore())
      Task { await model.load() }
      return model
    }
  }
#endif
