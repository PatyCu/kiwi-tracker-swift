import Foundation

/// An animal a Household cares for; every Member sees and manages it.
public struct Pet: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let name: String
  public let species: PetSpecies

  public init(id: UUID, name: String, species: PetSpecies) {
    self.id = id
    self.name = name
    self.species = species
  }
}

/// What kind of animal a Pet is, as the schema's `species` values.
public enum PetSpecies: String, Sendable {
  case cat = "Cat"
  case dog = "Dog"
  case other = "Other"
}

/// Why the Pets couldn't be read.
public enum PetStoreError: Error, Equatable, Sendable {
  /// Supabase couldn't be reached or the query failed.
  case couldNotLoad
  /// A stored Pet has a value the app doesn't know, such as an unknown species.
  case invalidData
}

/// Reads the signed-in Account's Household's Pets.
public protocol PetStore: Sendable {
  /// The Household's Pets, sorted by name, then id.
  func loadPets() async throws(PetStoreError) -> [Pet]
}
