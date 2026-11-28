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
    #expect(form.error != nil)
  }

  @Test func showsAnErrorAndLetsThePersonTryAgainWhenSignInFails() async {
    let auth = RecordingPasswordAuth()
    auth.answer(.failure(.invalidCredentials))
    let form = filledForm("alex@kiwi.test", "wrong", auth: auth)

    await form.submit()

    #expect(!form.signingIn)
    #expect(form.error != nil)

    form.password = "right"
    #expect(form.error == nil)
  }

  @Test func givesEachSignInProblemItsOwnMessage() async {
    let failures: [SignInError] = [
      .invalidCredentials, .emailNotConfirmed, .rateLimited, .network, .unknown,
    ]
    var messages: [String] = []
    for failure in failures {
      let auth = RecordingPasswordAuth()
      auth.answer(.failure(failure))
      let form = filledForm("alex@kiwi.test", "secret", auth: auth)
      await form.submit()
      messages.append(form.error ?? "")
    }
    let emptyForm = filledForm("", "")
    await emptyForm.submit()
    messages.append(emptyForm.error ?? "")

    #expect(!messages.contains(""))
    #expect(Set(messages).count == messages.count)
  }
}
