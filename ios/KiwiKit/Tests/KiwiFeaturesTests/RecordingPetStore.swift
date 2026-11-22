import Foundation
import KiwiDomain
import Synchronization

/// The Pets for tests: answers each load with the next of `answers`, in the order the loads
/// start, and counts them. `whileLoading` runs inside every load, before it answers. Saves are
/// recorded and stored as sent, with a new id for an added Pet, unless `saveFails` is set;
/// `whileSaving` runs inside every save, before it answers.
nonisolated final class RecordingPetStore: PetStore {
  enum Save: Equatable {
    case add(PetDetails, to: UUID)
    case update(UUID, PetDetails)
  }

  private let answers: Mutex<[Result<[Pet], PetStoreError>]>
  private let count = Mutex(0)
  private let recordedSaves = Mutex<[Save]>([])
  private let failing = Mutex(false)
  private let whileLoading: @Sendable () async -> Void
  private let whileSaving: @Sendable () async -> Void

  var loads: Int { count.withLock { $0 } }
  var saves: [Save] { recordedSaves.withLock { $0 } }
  var saveFails: Bool {
    get { failing.withLock { $0 } }
    set { failing.withLock { $0 = newValue } }
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
    return try answer.get()
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
    return Pet(
      id: id, name: details.name, species: details.species, breed: details.breed,
      birthDate: details.birthDate)
  }
}
