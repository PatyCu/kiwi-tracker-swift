import Foundation
import KiwiDomain
import Observation

/// The signed-in Account's Household Members. One model per sign-in, loaded apart from the
/// Household so a failure never keeps the tabs closed.
@Observable final class MembersModel {
  enum State: Equatable {
    case loading
    case ready([Member])
    case failed
  }

  private(set) var state = State.loading
  private let store: any HouseholdStore
  private let signedInAccountID: UUID
  private var attempt = 0

  init(store: any HouseholdStore, signedInAccountID: UUID) {
    self.store = store
    self.signedInAccountID = signedInAccountID
  }

  /// Whether `member` is the signed-in Account, whose row says "(you)".
  func isSignedIn(_ member: Member) -> Bool {
    member.accountID == signedInAccountID
  }

  /// Loads the Members unless a load has already started: once, when Settings first opens, so
  /// switching back to Settings doesn't reload.
  func loadOnce() async {
    guard attempt == 0 else { return }
    await load()
  }

  /// Loads the Members, showing loading while it runs. Calling it again is Retry.
  func load() async {
    attempt += 1
    let current = attempt
    state = .loading
    let next: State
    do {
      next = .ready(try await store.loadMembers())
    } catch {
      next = .failed
    }
    // Only the latest load decides, so an earlier one finishing late never shows stale data.
    if current == attempt { state = next }
  }
}
