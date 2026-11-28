import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let alex = Member(accountID: UUID(), displayName: "Alex")
private let sam = Member(accountID: UUID(), displayName: "Sam")

@Suite struct MembersModelTests {
  // Covers: HH-013
  @Test func showsTheHouseholdsMembersByName() async {
    let model = MembersModel(
      store: RecordingHouseholdStore(members: [.success([alex, sam])]),
      signedInAccountID: alex.accountID
    )

    #expect(model.state == .loading)
    await model.loadOnce()
    #expect(model.state == .ready([alex, sam]))
  }

  // Covers: HH-014
  @Test func marksOnlyTheSignedInAccountAsYou() {
    let model = MembersModel(
      store: RecordingHouseholdStore(),
      signedInAccountID: alex.accountID
    )

    #expect(model.isSignedIn(alex))
    #expect(!model.isSignedIn(sam))
  }

  // Covers: HH-017
  @Test func saysSoWhenTheMembersCannotBeLoadedAndRetries() async {
    let store = RecordingHouseholdStore(members: [.failure(.couldNotLoad), .success([alex])])
    let model = MembersModel(store: store, signedInAccountID: alex.accountID)
    await model.loadOnce()
    #expect(model.state == .failed)

    await model.load()

    #expect(model.state == .ready([alex]))
    #expect(store.memberLoads == 2)
  }

  // Covers: HH-018
  @Test func loadsOnlyOnceWhenSettingsOpensAgain() async {
    let store = RecordingHouseholdStore(members: [.success([alex])])
    let model = MembersModel(store: store, signedInAccountID: alex.accountID)

    await model.loadOnce()
    await model.loadOnce()

    #expect(model.state == .ready([alex]))
    #expect(store.memberLoads == 1)
  }

  @Test func ignoresAnEarlierLoadThatFinishesLast() async {
    let release = AsyncStream<Void>.makeStream()
    let first = Mutex(true)
    let store = RecordingHouseholdStore(members: [.success([sam]), .success([alex])]) {
      // The first load waits until the second has finished.
      let isFirst = first.withLock { isFirst in
        defer { isFirst = false }
        return isFirst
      }
      if isFirst {
        for await _ in release.stream { break }
      }
    }
    let model = MembersModel(store: store, signedInAccountID: alex.accountID)
    let earlier = Task { await model.loadOnce() }
    while store.memberLoads == 0 { await Task.yield() }

    await model.load()
    release.continuation.yield()
    await earlier.value

    #expect(model.state == .ready([alex]))
  }
}
