import KiwiDomain
import Synchronization

/// The Pets for tests: answers each load with the next of `answers`, in the order the loads
/// start, and counts them. `whileLoading` runs inside every load, before it answers.
nonisolated final class RecordingPetStore: PetStore {
  private let answers: Mutex<[Result<[Pet], PetStoreError>]>
  private let count = Mutex(0)
  private let whileLoading: @Sendable () async -> Void

  var loads: Int { count.withLock { $0 } }

  init(
    _ answers: Result<[Pet], PetStoreError>...,
    whileLoading: @escaping @Sendable () async -> Void = {}
  ) {
    self.answers = Mutex(answers)
    self.whileLoading = whileLoading
  }

  func loadPets() async throws(PetStoreError) -> [Pet] {
    count.withLock { $0 += 1 }
    let answer = answers.withLock { $0.removeFirst() }
    await whileLoading()
    return try answer.get()
  }
}
