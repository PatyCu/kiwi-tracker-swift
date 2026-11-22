import Foundation
import KiwiDomain
import Supabase

/// The signed-in Account's Household's Pets from the `pets` table, as the reference app's
/// `petStore`.
public struct SupabasePetStore: PetStore {
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
        .select("id, name, species")
        .order("name")
        .order("id")
        .execute().value
    } catch {
      throw .couldNotLoad
    }
    // An unknown species fails the whole load, as the reference does, rather than guessing.
    return try rows.map { row throws(PetStoreError) in
      guard let species = PetSpecies(rawValue: row.species) else { throw .invalidData }
      return Pet(id: row.id, name: row.name, species: species)
    }
  }
}

/// The `pets` columns `loadPets()` selects.
private struct PetRow: Decodable {
  let id: UUID
  let name: String
  let species: String
}
