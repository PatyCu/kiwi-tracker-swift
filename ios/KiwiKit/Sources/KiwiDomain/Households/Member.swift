import Foundation

/// An Account in the signed-in Account's Household, known there by its Display name.
public struct Member: Equatable, Sendable {
  public let accountID: UUID
  /// What the Member is called in their Household, without spaces or newlines at either end.
  /// The schema rejects Display names that are only spaces.
  public let displayName: String

  public init(accountID: UUID, displayName: String) {
    self.accountID = accountID
    self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
