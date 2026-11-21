import Testing

@testable import KiwiFeatures

private struct SignOutFailed: Error {}

@Suite struct SignOutModelTests {
  @Test func startsReadyToSignOut() {
    let model = SignOutModel()

    #expect(!model.signingOut)
    #expect(model.error == nil)
  }

  @Test func staysSigningOutWhenItSucceeds() async {
    let model = SignOutModel()

    await model.signOut {}

    // The session replaces the section with sign-in.
    #expect(model.signingOut)
    #expect(model.error == nil)
  }

  @Test func showsTheErrorAndAllowsRetryWhenItFails() async {
    let model = SignOutModel()

    await model.signOut { throw SignOutFailed() }

    #expect(!model.signingOut)
    #expect(model.error == "Could not sign out. Try again.")
  }

  @Test func clearsTheErrorWhenRetrying() async {
    let model = SignOutModel()
    await model.signOut { throw SignOutFailed() }

    await model.signOut {
      #expect(model.signingOut)
      #expect(model.error == nil)
    }
  }

  @Test func ignoresATapWhileSigningOut() async {
    let model = SignOutModel()
    var calls = 0
    await model.signOut { calls += 1 }

    await model.signOut { calls += 1 }

    #expect(calls == 1)
  }
}
