import KiwiDomain
import Testing

@testable import KiwiFeatures

private func filledForm(
  _ email: String,
  _ password: String,
  auth: RecordingPasswordAuth = RecordingPasswordAuth()
) -> PasswordSignInForm {
  let form = PasswordSignInForm(auth: auth)
  form.email = email
  form.password = password
  return form
}

nonisolated private let missingFields = [("", "secret"), ("alex@kiwi.test", "")]

@Suite struct PasswordSignInFormTests {
  @Test func signsInWithTheNormalizedEmailAndThePasswordAsTyped() async {
    let auth = RecordingPasswordAuth()
    let form = filledForm("  Alex@Kiwi.test ", " pass word ", auth: auth)

    await form.submit()

    #expect(auth.attempts.map(\.email) == ["alex@kiwi.test"])
    #expect(auth.attempts.map(\.password) == [" pass word "])
    #expect(form.signingIn)
    #expect(form.error == nil)
  }

  @Test(arguments: missingFields)
  func asksForBothFieldsWithoutCallingTheServer(email: String, password: String) async {
    let auth = RecordingPasswordAuth()
    let form = filledForm(email, password, auth: auth)

    await form.submit()

    #expect(auth.attempts.isEmpty)
    #expect(form.error == "Enter your email and password.")
  }

  @Test func showsTheErrorAndLetsThePersonTryAgainWhenSignInFails() async {
    let auth = RecordingPasswordAuth()
    auth.answer(.failure(.invalidCredentials))
    let form = filledForm("alex@kiwi.test", "wrong", auth: auth)

    await form.submit()

    #expect(!form.signingIn)
    #expect(form.error == "That email and password don’t match an account.")

    form.password = "right"
    #expect(form.error == nil)
  }

  @Test func treatsUnexpectedErrorsAsUnknown() async {
    let auth = RecordingPasswordAuth()
    auth.answer(.failure(.unknown))
    let form = filledForm("alex@kiwi.test", "secret", auth: auth)

    await form.submit()

    #expect(form.error == "Something went wrong. Try again.")
  }
}
