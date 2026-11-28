import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let alexsHome = Household(id: UUID(), alias: "Alex's home")

@Suite struct HouseholdModelTests {
  // Covers: HH-001
  @Test func loadsTheSignedInAccountsHousehold() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(alexsHome)))

    #expect(model.state == .loading)
    await model.load()
    #expect(model.state == .ready(alexsHome))
  }

  // Covers: HH-003
  @Test func reportsASignedInAccountWithoutAHouseholdAsMissing() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(nil)))

    await model.load()

    #expect(model.state == .missing)
  }

  // Covers: HH-002, HH-004
  @Test func keepsAFailedLoadApartFromAMissingHousehold() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.failure(.couldNotLoad)))

    await model.load()

    #expect(model.state == .failed)
  }

  // Covers: HH-005
  @Test func checksAgainOnRetrySoANewlyAddedMembershipIsPickedUp() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(nil), .success(alexsHome)))
    await model.load()
    #expect(model.state == .missing)

    await model.load()

    #expect(model.state == .ready(alexsHome))
  }

  // Covers: HH-002
  @Test func showsLoadingAgainWhileARetryAfterAFailedLoadRuns() async {
    let states = Mutex<[HouseholdModel.State]>([])
    let box = ModelBox()
    let model = HouseholdModel(
      store: RecordingHouseholdStore(.failure(.couldNotLoad), .success(alexsHome)) {
        let state = await MainActor.run { box.model?.state }
        if let state { states.withLock { $0.append(state) } }
      }
    )
    box.model = model
    await model.load()
    #expect(model.state == .failed)

    await model.load()

    #expect(states.withLock { $0 } == [.loading, .loading])
    #expect(model.state == .ready(alexsHome))
  }

  // Covers: HH-007
  @Test func ignoresAnEarlierLoadThatFinishesLast() async {
    let release = AsyncStream<Void>.makeStream()
    let first = Mutex(true)
    let store = RecordingHouseholdStore(.success(nil), .success(alexsHome)) {
      // The first load waits until the second has finished.
      let isFirst = first.withLock { isFirst in
        defer { isFirst = false }
        return isFirst
      }
      if isFirst {
        for await _ in release.stream { break }
      }
    }
    let model = HouseholdModel(store: store)
    let earlier = Task { await model.load() }
    while store.loads == 0 { await Task.yield() }

    await model.load()
    release.continuation.yield()
    await earlier.value

    #expect(model.state == .ready(alexsHome))
  }
}

/// Lets the store's hook read the model it was made for.
private final class ModelBox {
  var model: HouseholdModel?
}
