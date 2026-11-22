#if DEBUG
  import Foundation
  import KiwiDomain

  extension Pet {
    /// The preview Household's Pets, sorted by name, as the seeded shared Household's.
    nonisolated static let previews = [
      Pet(id: UUID(), name: "Kiwi", species: .cat),
      Pet(id: UUID(), name: "Luna", species: .dog),
    ]
  }

  /// The Pets for previews: loads them, fails, or never finishes.
  nonisolated struct PreviewPetStore: PetStore {
    enum Outcome {
      case loads([Pet])
      case fails
      case staysLoading
    }

    var outcome = Outcome.loads(Pet.previews)

    func loadPets() async throws(PetStoreError) -> [Pet] {
      switch outcome {
      case .loads(let pets): return pets
      case .fails: throw .couldNotLoad
      case .staysLoading:
        try? await Task.sleep(for: .seconds(3600))
        return []
      }
    }
  }

  extension PetsModel {
    /// Pets for previews, already loading from `PreviewPetStore`, as the app starts the load at
    /// sign-in.
    static func preview(_ outcome: PreviewPetStore.Outcome = .loads(Pet.previews)) -> PetsModel {
      let model = PetsModel(store: PreviewPetStore(outcome: outcome))
      Task { await model.load() }
      return model
    }
  }
#endif
