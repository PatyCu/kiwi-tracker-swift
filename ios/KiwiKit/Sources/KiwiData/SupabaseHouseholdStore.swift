import Foundation
import KiwiDomain
import Supabase

/// The signed-in Account's Household from the `households` table, as the reference app's
/// `householdStore`.
public struct SupabaseHouseholdStore: HouseholdStore {
  private let backend: SupabaseBackend

  public init(backend: SupabaseBackend) {
    self.backend = backend
  }

  public func loadHousehold() async throws(HouseholdStoreError) -> Household? {
    let rows: [PublicSchema.HouseholdsSelect]
    do {
      rows = try await backend.client.from("households").select("id, alias").execute().value
    } catch {
      throw .couldNotLoad
    }
    // Access rules return only the Account's own Household, and it belongs to at most one;
    // more than one row is an error, as supabase-js's `maybeSingle()` treats it.
    guard rows.count <= 1 else { throw .couldNotLoad }
    return rows.first.map { Household(id: $0.id, alias: $0.alias) }
  }
}
