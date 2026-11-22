import Foundation
import KiwiDomain
import Testing

/// The reference's pet details rules: `usePetProfileForm`'s validation, `savePetProfile`'s
/// trimming, and the date of birth as a calendar day.
@Suite struct PetDetailsTests {
  @Test func trimsTheNameAndBreedAndSavesAnEmptyBreedAsNone() {
    #expect(
      PetDetails(name: " Murri ", species: .cat, breed: "  ").normalized()
        == PetDetails(name: "Murri", species: .cat))
    #expect(
      PetDetails(name: "Kiwi", species: .cat, breed: " Tabby ").normalized().breed == "Tabby")
  }

  @Test(arguments: ["", "   "])
  func needsAName(name: String) {
    #expect(!PetDetails(name: name, species: .cat).isValid(now: today, calendar: madrid))
  }

  @Test func acceptsNoDateOfBirthOrOneUpToToday() {
    let details = { (day: BirthDate?) in PetDetails(name: "Miso", species: .cat, birthDate: day) }

    #expect(details(nil).isValid(now: today, calendar: madrid))
    #expect(
      details(BirthDate(year: 2026, month: 11, day: 22)).isValid(now: today, calendar: madrid))
    #expect(
      !details(BirthDate(year: 2026, month: 11, day: 23)).isValid(now: today, calendar: madrid))
  }

  @Test func keepsTheDayChosenWhateverTheTimeZone() {
    // 23:30 on 22 November in Madrid is already the 23rd in Tokyo.
    let lateEvening = Date(timeIntervalSince1970: 1_795_386_600)
    let chosen = BirthDate(lateEvening, in: madrid)

    #expect(chosen == BirthDate(year: 2026, month: 11, day: 22))
    #expect(BirthDate(lateEvening, in: tokyo) == BirthDate(year: 2026, month: 11, day: 23))
    #expect(BirthDate(chosen.date(in: tokyo), in: tokyo) == chosen)
  }
}

private let madrid = calendar("Europe/Madrid")
private let tokyo = calendar("Asia/Tokyo")
/// Noon on 22 November 2026 in Madrid.
private let today = Date(timeIntervalSince1970: 1_795_345_200)

private func calendar(_ timeZone: String) -> Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: timeZone) ?? .gmt
  return calendar
}
