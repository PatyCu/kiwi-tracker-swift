import Foundation
import KiwiDomain
import Supabase

/// The signed-in Account's Household's Pets in the `pets` table, as the reference app's
/// `petStore`.
public struct SupabasePetStore: PetStore {
  private static let columns = "id, name, species, breed, birth_date"
  private let backend: SupabaseBackend

  public init(backend: SupabaseBackend) {
    self.backend = backend
  }

  public func loadPets() async throws(PetStoreError) -> [Pet] {
    let rows: [PetRow]
    do {
      // Access rules return only the Household's Pets. Ordering by id after name keeps Pets
      // with the same name in the same order on every device.
      rows = try await backend.client.from("pets")
        .select(Self.columns)
        .order("name")
        .order("id")
        .execute().value
    } catch {
      throw .couldNotLoad
    }
    // An unknown species fails the whole load, as the reference does, rather than guessing.
    return try rows.map { row throws(PetStoreError) in try row.pet() }
  }

  public func addPet(_ details: PetDetails, to householdID: UUID) async throws(PetStoreError)
    -> Pet
  {
    try await write {
      try await backend.client.from("pets")
        .insert(PetColumns(details, householdID: householdID))
        .select(Self.columns)
        .single()
        .execute().value
    }
  }

  /// Fails when the Pet no longer exists or belongs to another Household: access rules then
  /// match no row, so `single()` finds none.
  public func updatePet(_ id: UUID, _ details: PetDetails) async throws(PetStoreError) -> Pet {
    try await write {
      try await backend.client.from("pets")
        .update(PetColumns(details))
        .eq("id", value: id)
        .select(Self.columns)
        .single()
        .execute().value
    }
  }

  /// Runs a write that answers with the stored row. A stored row the app can't read is reported
  /// as not saved too: the Pet can't be shown as saved.
  private func write(_ request: () async throws -> PetRow) async throws(PetStoreError) -> Pet {
    do {
      return try await request().pet()
    } catch {
      throw .couldNotSave
    }
  }
}

/// The `pets` columns the store selects.
private struct PetRow: Decodable {
  let id: UUID
  let name: String
  let species: String
  let breed: String?
  let birthDate: String?

  enum CodingKeys: String, CodingKey {
    case id, name, species, breed
    case birthDate = "birth_date"
  }

  func pet() throws(PetStoreError) -> Pet {
    guard let species = PetSpecies(rawValue: species) else { throw .invalidData }
    var birthDay: BirthDate?
    if let birthDate {
      guard let day = BirthDate(stored: birthDate) else { throw .invalidData }
      birthDay = day
    }
    return Pet(
      id: id, name: name, species: species, breed: breed.flatMap { $0.isEmpty ? nil : $0 },
      birthDate: birthDay)
  }
}

/// The `pets` columns a Member's details write. An empty breed or a missing date of birth is
/// written as null, so saving clears it. `household_id` is only sent when adding.
private struct PetColumns: Encodable {
  let householdID: UUID?
  let details: PetDetails

  init(_ details: PetDetails, householdID: UUID? = nil) {
    self.details = details
    self.householdID = householdID
  }

  enum CodingKeys: String, CodingKey {
    case householdID = "household_id"
    case name, species, breed
    case birthDate = "birth_date"
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(householdID, forKey: .householdID)
    try container.encode(details.name, forKey: .name)
    try container.encode(details.species.rawValue, forKey: .species)
    try container.encode(details.breed.flatMap { $0.isEmpty ? nil : $0 }, forKey: .breed)
    try container.encode(details.birthDate?.stored, forKey: .birthDate)
  }
}

extension BirthDate {
  /// The schema's `date` value, `YYYY-MM-DD`.
  fileprivate init?(stored: String) {
    let parts = stored.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3 else { return nil }
    self.init(year: parts[0], month: parts[1], day: parts[2])
  }

  fileprivate var stored: String {
    String(format: "%04d-%02d-%02d", year, month, day)
  }
}
