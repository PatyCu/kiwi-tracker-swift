import Foundation
import KiwiDomain
import Synchronization

/// The Pets for tests: answers each load with the next of `answers`, in the order the loads
/// start, and counts them. `whileLoading` runs inside every load, before it answers. Saves are
/// recorded and stored as sent, with a new id for an added Pet, unless `saveFails` is set; an
/// updated Pet keeps the photo path it was loaded or last saved with. Recording a photo path fails
/// while `photoPathFails` is set. `whileSaving` runs inside every save, before it answers.
nonisolated final class RecordingPetStore: PetStore {
  enum Save: Equatable {
    case add(PetDetails, to: UUID)
    case update(UUID, PetDetails)
    case photoPath(String, of: UUID)
  }

  private let answers: Mutex<[Result<[Pet], PetStoreError>]>
  private let count = Mutex(0)
  private let recordedSaves = Mutex<[Save]>([])
  private let failing = Mutex(false)
  private let photoPathFailing = Mutex(false)
  /// Each Pet's stored details and photo path, by id.
  private let stored = Mutex<[UUID: Pet]>([:])
  private let whileLoading: @Sendable () async -> Void
  private let whileSaving: @Sendable () async -> Void

  var loads: Int { count.withLock { $0 } }
  var saves: [Save] { recordedSaves.withLock { $0 } }
  var saveFails: Bool {
    get { failing.withLock { $0 } }
    set { failing.withLock { $0 = newValue } }
  }
  var photoPathFails: Bool {
    get { photoPathFailing.withLock { $0 } }
    set { photoPathFailing.withLock { $0 = newValue } }
  }

  init(
    _ answers: Result<[Pet], PetStoreError>...,
    whileLoading: @escaping @Sendable () async -> Void = {},
    whileSaving: @escaping @Sendable () async -> Void = {}
  ) {
    self.answers = Mutex(answers)
    self.whileLoading = whileLoading
    self.whileSaving = whileSaving
  }

  func loadPets() async throws(PetStoreError) -> [Pet] {
    count.withLock { $0 += 1 }
    let answer = answers.withLock { $0.removeFirst() }
    await whileLoading()
    let pets = try answer.get()
    stored.withLock { stored in
      for pet in pets { stored[pet.id] = pet }
    }
    return pets
  }

  func addPet(_ details: PetDetails, to householdID: UUID) async throws(PetStoreError) -> Pet {
    try await save(.add(details, to: householdID), id: UUID(), details)
  }

  func updatePet(_ id: UUID, _ details: PetDetails) async throws(PetStoreError) -> Pet {
    try await save(.update(id, details), id: id, details)
  }

  private func save(_ save: Save, id: UUID, _ details: PetDetails) async throws(PetStoreError)
    -> Pet
  {
    recordedSaves.withLock { $0.append(save) }
    await whileSaving()
    if saveFails { throw .couldNotSave }
    return keep(details, photoPath: stored.withLock { $0[id]?.photoPath }, id: id)
  }

  func setPhotoPath(_ path: String, of id: UUID) async throws(PetStoreError) -> Pet {
    recordedSaves.withLock { $0.append(.photoPath(path, of: id)) }
    guard !photoPathFails, let pet = stored.withLock({ $0[id] }) else { throw .couldNotSave }
    return keep(pet.details, photoPath: path, id: id)
  }

  private func keep(_ details: PetDetails, photoPath: String?, id: UUID) -> Pet {
    let pet = Pet(
      id: id, name: details.name, species: details.species, breed: details.breed,
      birthDate: details.birthDate, photoPath: photoPath)
    stored.withLock { $0[id] = pet }
    return pet
  }
}
