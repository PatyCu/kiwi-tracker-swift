import Foundation

/// The Household the signed-in Account belongs to; it owns the pets its Members share.
public struct Household: Equatable, Sendable {
  public let id: UUID
  /// What Members call their Household, shown in titles.
  public let alias: String

  public init(id: UUID, alias: String) {
    self.id = id
    self.alias = alias
  }
}

/// Why the Household couldn't be read.
public enum HouseholdStoreError: Error, Equatable, Sendable {
  /// Supabase couldn't be reached or the query failed.
  case couldNotLoad
}

/// Reads the signed-in Account's Household.
public protocol HouseholdStore: Sendable {
  /// The signed-in Account's Household, or `nil` when it isn't in one yet.
  func loadHousehold() async throws(HouseholdStoreError) -> Household?
}
