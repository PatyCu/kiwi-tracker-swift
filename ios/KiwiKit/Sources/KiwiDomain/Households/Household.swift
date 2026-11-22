import Foundation

/// The Household the signed-in Account belongs to; it owns the pets its Members share.
public struct Household: Equatable, Sendable {
  public let id: UUID
  /// What Members call their Household, shown in titles, without spaces or newlines at either
  /// end. The schema rejects aliases that are only spaces.
  public let alias: String

  public init(id: UUID, alias: String) {
    self.id = id
    self.alias = alias.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

/// Why the Household or its Members couldn't be read.
public enum HouseholdStoreError: Error, Equatable, Sendable {
  /// Supabase couldn't be reached or the query failed.
  case couldNotLoad
}

/// Reads the signed-in Account's Household and its Members.
public protocol HouseholdStore: Sendable {
  /// The signed-in Account's Household, or `nil` when it isn't in one yet.
  func loadHousehold() async throws(HouseholdStoreError) -> Household?
  /// The Members of the signed-in Account's Household, the Account included, sorted by Display
  /// name.
  func loadMembers() async throws(HouseholdStoreError) -> [Member]
}
