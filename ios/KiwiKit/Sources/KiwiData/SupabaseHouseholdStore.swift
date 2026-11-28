import Foundation
import KiwiDomain
import Supabase

/// The signed-in Account's Household and its Members from the `households` and
/// `household_members` tables.
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
    // more than one row is an error rather than a guess at which one is theirs.
    guard rows.count <= 1 else { throw .couldNotLoad }
    return rows.first.map { Household(id: $0.id, alias: $0.alias) }
  }

  public func loadMembers() async throws(HouseholdStoreError) -> [Member] {
    let rows: [MemberRow]
    do {
      // Access rules return only memberships of the Account's own Household.
      rows = try await backend.client.from("household_members")
        .select("user_id, display_name")
        .order("display_name")
        .execute().value
    } catch {
      throw .couldNotLoad
    }
    return rows.map { Member(accountID: $0.userId, displayName: $0.displayName) }
  }
}

/// The `household_members` columns `loadMembers()` selects.
private struct MemberRow: Decodable {
  let userId: UUID
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case displayName = "display_name"
  }
}
