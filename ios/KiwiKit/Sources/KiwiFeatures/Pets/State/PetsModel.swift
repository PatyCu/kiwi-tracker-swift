import Foundation
import KiwiDomain
import Observation

/// The signed-in Account's Household's Pets, as the reference app's `PetsProvider`. One model per
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
}

/// The Pet the Pets tab shows: the one with `id`, or the first when none is chosen or the
/// chosen one is gone, as the reference's `PetsScreen`.
func selectedPet(_ id: UUID?, in pets: [Pet]) -> Pet? {
  pets.first { $0.id == id } ?? pets.first
}
