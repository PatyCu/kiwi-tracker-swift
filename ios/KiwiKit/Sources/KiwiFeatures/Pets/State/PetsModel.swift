import Foundation
import KiwiDomain
import Observation

/// The signed-in Account's Household's Pets: loads them and saves a Member's changes. One model per
/// sign-in, so a new Account never sees the previous Pets.
@Observable final class PetsModel {
  enum State: Equatable {
    case loading
    case ready([Pet])
    case failed
  }

  private(set) var state = State.loading
  private let store: any PetStore
  private var attempt = 0

  init(store: any PetStore) {
    self.store = store
  }

  /// Loads the Pets, showing loading while it runs. Calling it again is Retry.
  func load() async {
    attempt += 1
    let current = attempt
    state = .loading
    let next: State
    do {
      next = .ready(try await store.loadPets())
    } catch {
      next = .failed
    }
    // Only the latest load decides, so an earlier one finishing late never shows stale data.
    if current == attempt { state = next }
  }

  /// Adds a Pet with `details` to the Household with `householdID`, or, with `editing`, saves them
  /// to that Pet. The stored Pet goes into the list in name order at once, leaving the selection as
  /// it is. Saving needs the Pets loaded, and editing a Pet no longer in the list fails without
  /// saving, so the wrong Pet is never recreated or overwritten.
  func save(_ details: PetDetails, editing: UUID?, householdID: UUID) async throws(PetStoreError) {
    guard case .ready(let pets) = state else { throw .couldNotSave }
    let stored: Pet
    if let editing {
      guard pets.contains(where: { $0.id == editing }) else { throw .couldNotSave }
      stored = try await store.updatePet(editing, details)
    } else {
      stored = try await store.addPet(details, to: householdID)
    }
    // A load that started meanwhile replaces the list anyway, and shows this Pet.
    guard case .ready(let current) = state else { return }
    state = .ready((current.filter { $0.id != stored.id } + [stored]).sorted(by: nameOrder))
  }
}

/// The loaded Pets' order: by name, then id, as the store sorts them.
private func nameOrder(_ lhs: Pet, _ rhs: Pet) -> Bool {
  switch lhs.name.localizedCompare(rhs.name) {
  case .orderedAscending: true
  case .orderedDescending: false
  case .orderedSame: lhs.id.uuidString < rhs.id.uuidString
  }
}

/// The Pet the Pets tab shows: the one with `id`, or the first when none is chosen or the
/// chosen one is gone, so a Household with Pets always shows one.
func selectedPet(_ id: UUID?, in pets: [Pet]) -> Pet? {
  pets.first { $0.id == id } ?? pets.first
}
