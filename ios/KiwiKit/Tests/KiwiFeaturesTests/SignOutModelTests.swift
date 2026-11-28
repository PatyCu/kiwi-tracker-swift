import Testing

@testable import KiwiFeatures

@Suite struct SignOutModelTests {
  // Covers: AUTH-017
  @Test func staysSigningOutWhenItSucceeds() async {
    let model = SignOutModel()

    await model.signOut {}

    // The session replaces the section with sign-in.
    #expect(model.signingOut)
    #expect(model.error == nil)
  }

  // Covers: AUTH-018
  @Test func showsAnErrorAndAllowsRetryWhenItFails() async {
    let model = SignOutModel()

    await model.signOut { throw SignOutFailed() }

    #expect(!model.signingOut)
    #expect(model.error != nil)
  }

  // Covers: AUTH-018
  @Test func clearsTheErrorWhenRetrying() async {
    let model = SignOutModel()
    await model.signOut { throw SignOutFailed() }

    await model.signOut {
      #expect(model.signingOut)
      #expect(model.error == nil)
    }
  }

  // Covers: AUTH-017
  @Test func ignoresATapWhileSigningOut() async {
    let model = SignOutModel()
    var calls = 0
    await model.signOut { calls += 1 }

    await model.signOut { calls += 1 }

    #expect(calls == 1)
  }
}
