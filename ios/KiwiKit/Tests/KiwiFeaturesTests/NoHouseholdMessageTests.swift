import Testing

@testable import KiwiFeatures

@Suite struct NoHouseholdMessageTests {
  // Covers: HH-003
  @Test func namesTheAccountByItsEmailOnlyWhenTheEmailIsKnown() {
    let missing = noHouseholdMessage(email: nil)

    #expect(noHouseholdMessage(email: "") == missing)
    #expect(noHouseholdMessage(email: "jo@kiwi.test").contains("jo@kiwi.test"))
  }
}
