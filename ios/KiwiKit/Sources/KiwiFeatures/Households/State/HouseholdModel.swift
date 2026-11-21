import KiwiDomain
import Observation

/// The signed-in Account's Household, as the reference app's `HouseholdProvider`. One model per
/// sign-in, so a new Account never sees the previous Household.
@Observable final class HouseholdModel {
  enum State: Equatable {
    case loading
    case ready(Household)
    /// Signed in, but the Account was never added to a Household: a setup mistake.
    case missing
    case failed
  }

  private(set) var state = State.loading
  private let store: any HouseholdStore
  private var attempt = 0

  init(store: any HouseholdStore) {
    self.store = store
  }

  /// Loads the Household, showing loading while it runs. Calling it again is Retry and
  /// "Check again": it picks up a membership added since the last load.
  func load() async {
    attempt += 1
    let current = attempt
    state = .loading
    let next: State
    do {
      next = try await store.loadHousehold().map(State.ready) ?? .missing
    } catch {
      next = .failed
    }
    // Only the latest load decides, so an earlier one finishing late never shows stale data.
    if current == attempt { state = next }
  }
}
