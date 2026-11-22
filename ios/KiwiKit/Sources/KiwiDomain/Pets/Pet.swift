import Foundation

/// An animal a Household cares for; every Member sees and manages it. It has a name and a
/// species, and may have a breed and a date of birth.
public struct Pet: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let name: String
  public let species: PetSpecies
  public let breed: String?
  public let birthDate: BirthDate?

  public init(
    id: UUID, name: String, species: PetSpecies, breed: String? = nil, birthDate: BirthDate? = nil
  ) {
    self.id = id
    self.name = name
    self.species = species
    self.breed = breed
    self.birthDate = birthDate
  }

  /// What a Member entered for this Pet.
  public var details: PetDetails {
    PetDetails(name: name, species: species, breed: breed, birthDate: birthDate)
  }
}

/// What kind of animal a Pet is, as the schema's `species` values.
public enum PetSpecies: String, CaseIterable, Sendable {
  case cat = "Cat"
  case dog = "Dog"
  case other = "Other"
}

/// What a Member enters for a Pet, as the reference app's `PetProfile`; the id comes from
/// storage.
public struct PetDetails: Equatable, Sendable {
  public var name: String
  public var species: PetSpecies
  /// `nil` when the Pet has no breed.
  public var breed: String?
  public var birthDate: BirthDate?

  public init(name: String, species: PetSpecies, breed: String? = nil, birthDate: BirthDate? = nil)
  {
    self.name = name
    self.species = species
    self.breed = breed
    self.birthDate = birthDate
  }

  /// The details as saved: name and breed without spaces or newlines at either end, and an
  /// empty breed as none.
  public func normalized() -> PetDetails {
    let breed = breed?.trimmingCharacters(in: .whitespacesAndNewlines)
    return PetDetails(
      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
      species: species,
      breed: breed?.isEmpty == false ? breed : nil,
      birthDate: birthDate
    )
  }

  /// Every Pet has a name, and its date of birth, if any, is no later than today.
  public func isValid(now: Date, calendar: Calendar) -> Bool {
    !normalized().name.isEmpty && (birthDate?.isValid(now: now, calendar: calendar) ?? true)
  }
}

/// A Pet's date of birth: a calendar day, never a moment in time, so it shows the same day in
/// every time zone.
public struct BirthDate: Comparable, Sendable {
  public let year: Int
  public let month: Int
  public let day: Int

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  /// The day `date` falls on in `calendar`.
  public init(_ date: Date, in calendar: Calendar) {
    let parts = calendar.dateComponents([.year, .month, .day], from: date)
    self.init(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0)
  }

  /// The start of this day in `calendar`, for a date picker.
  public func date(in calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
  }

  /// A date of birth can be today or earlier, never in the future.
  public func isValid(now: Date, calendar: Calendar) -> Bool {
    self <= BirthDate(now, in: calendar)
  }

  public static func < (lhs: BirthDate, rhs: BirthDate) -> Bool {
    (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
  }
}

/// Why the Pets couldn't be read or saved.
public enum PetStoreError: Error, Equatable, Sendable {
  /// Supabase couldn't be reached or the query failed.
  case couldNotLoad
  /// A stored Pet has a value the app doesn't know, such as an unknown species.
  case invalidData
  /// The Pet couldn't be confirmed as saved: the write failed, its answer was lost, or the Pet
  /// is gone.
  case couldNotSave
}

/// Reads and saves the signed-in Account's Household's Pets.
public protocol PetStore: Sendable {
  /// The Household's Pets, sorted by name, then id.
  func loadPets() async throws(PetStoreError) -> [Pet]
  /// Adds a Pet with `details` to the Household with `householdID`, and returns it as stored.
  func addPet(_ details: PetDetails, to householdID: UUID) async throws(PetStoreError) -> Pet
  /// Saves `details` to the Pet with `id`, and returns it as stored.
  func updatePet(_ id: UUID, _ details: PetDetails) async throws(PetStoreError) -> Pet
}
