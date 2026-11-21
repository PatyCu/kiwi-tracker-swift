import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let alexsHome = Household(id: UUID(), alias: "Alex's home")
private let samsHome = Household(id: UUID(), alias: "Sam's home")

@Suite struct HouseholdModelTests {
  @Test func loadsTheSignedInAccountsHousehold() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(alexsHome)))

    #expect(model.state == .loading)
    await model.load()
    #expect(model.state == .ready(alexsHome))
  }

  @Test func reportsASignedInAccountWithoutAHouseholdAsMissing() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(nil)))

    await model.load()

    #expect(model.state == .missing)
  }

  @Test func keepsAFailedLoadApartFromAMissingHousehold() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.failure(.couldNotLoad)))

    await model.load()

    #expect(model.state == .failed)
  }

  @Test func checksAgainOnRetrySoANewlyAddedMembershipIsPickedUp() async {
    let model = HouseholdModel(store: RecordingHouseholdStore(.success(nil), .success(alexsHome)))
    await model.load()
    #expect(model.state == .missing)

    await model.load()

    #expect(model.state == .ready(alexsHome))
  }

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

  /// The app makes a new model for each sign-in (`AppRoot`), so the next Account starts from
  /// loading and never sees the previous Household.
  @Test func loadsAgainForADifferentAccountInsteadOfShowingThePreviousHousehold() async {
    let alexsModel = HouseholdModel(store: RecordingHouseholdStore(.success(alexsHome)))
    await alexsModel.load()
    #expect(alexsModel.state == .ready(alexsHome))

    let samsModel = HouseholdModel(store: RecordingHouseholdStore(.success(samsHome)))

    #expect(samsModel.state == .loading)
    await samsModel.load()
    #expect(samsModel.state == .ready(samsHome))
  }

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
