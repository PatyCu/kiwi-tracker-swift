import KiwiDomain
import Synchronization

/// The Household for tests: answers each Household load with the next of `answers`, and each
/// Members load with the next of `members`, in the order the loads start, and counts them.
/// `whileLoading` runs inside every load, before it answers.
nonisolated final class RecordingHouseholdStore: HouseholdStore {
  private let answers: Mutex<[Result<Household?, HouseholdStoreError>]>
  private let memberAnswers: Mutex<[Result<[Member], HouseholdStoreError>]>
  private let count = Mutex(0)
  private let memberCount = Mutex(0)
  private let whileLoading: @Sendable () async -> Void

  var loads: Int { count.withLock { $0 } }
  var memberLoads: Int { memberCount.withLock { $0 } }

  init(
    _ answers: Result<Household?, HouseholdStoreError>...,
    members: [Result<[Member], HouseholdStoreError>] = [],
    whileLoading: @escaping @Sendable () async -> Void = {}
  ) {
    self.answers = Mutex(answers)
    memberAnswers = Mutex(members)
    self.whileLoading = whileLoading
  }

  func loadHousehold() async throws(HouseholdStoreError) -> Household? {
    count.withLock { $0 += 1 }
    let answer = answers.withLock { $0.removeFirst() }
    await whileLoading()
    return try answer.get()
  }

  func loadMembers() async throws(HouseholdStoreError) -> [Member] {
    memberCount.withLock { $0 += 1 }
    let answer = memberAnswers.withLock { $0.removeFirst() }
    await whileLoading()
    return try answer.get()
  }
}
