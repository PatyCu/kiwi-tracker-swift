import Foundation
import KiwiDomain
import Testing

@testable import KiwiFeatures

private struct SignOutFailed: Error {}

/// The reference's `NoHouseholdScreen` cases, against the pieces the screen is built from: its
/// copy, `HouseholdModel` for Check again and `SignOutModel` (Auth's `SignOutButton`) for Sign out.
@Suite struct NoHouseholdScreenTests {
  @Test func explainsThatTheAccountNeedsAHouseholdInsteadOfOpeningAnEmptyApp() {
    #expect(
      noHouseholdMessage(email: "jo@kiwi.test")
        == "jo@kiwi.test needs to be added to a household before you can use Kiwi Tracker. "
        + "Ask whoever set up your account, then check again."
    )
    #expect(noHouseholdMessage(email: nil).hasPrefix("Your account needs to be added"))
  }

  @Test func checksAgainAndSignsOut() async {
    let store = RecordingHouseholdStore(.success(nil), .success(nil))
    let household = HouseholdModel(store: store)
    await household.load()
    let auth = RecordingPasswordAuth()
    let session = SessionModel(auth: auth)

    await household.load()
    await SignOutModel().signOut(with: session.signOut)

    #expect(store.loads == 2)
    #expect(auth.signOuts == 1)
  }

  @Test func saysSoWhenSigningOutFails() async {
    let model = SignOutModel()

    await model.signOut { throw SignOutFailed() }

    #expect(model.error == "Could not sign out. Try again.")
  }
}
