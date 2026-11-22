#if DEBUG
  import Foundation
  import KiwiDomain

  extension Household {
    nonisolated static let preview = Household(id: UUID(), alias: "The Burrow")
  }

  extension Member {
    /// The preview Household's Members, sorted by Display name; Alex is `SignedInUser.preview`.
    nonisolated static let previews = [
      Member(accountID: SignedInUser.preview.id, displayName: "Alex"),
      Member(accountID: UUID(), displayName: "Sam"),
    ]
  }

  /// The Household for previews: loads one, finds none, fails, or never finishes. Members load
  /// as `Member.previews` alongside a loaded Household, and fail or never finish with it.
  nonisolated struct PreviewHouseholdStore: HouseholdStore {
    enum Outcome {
      case loads(Household)
      case missing
      case fails
      case staysLoading
    }

    var outcome = Outcome.loads(.preview)

    func loadHousehold() async throws(HouseholdStoreError) -> Household? {
      switch outcome {
      case .loads(let household): return household
      case .missing: return nil
      case .fails: throw .couldNotLoad
      case .staysLoading:
        try? await Task.sleep(for: .seconds(3600))
        return nil
      }
    }

    func loadMembers() async throws(HouseholdStoreError) -> [Member] {
      switch outcome {
      case .loads: return Member.previews
      case .missing: return []
      case .fails: throw .couldNotLoad
      case .staysLoading:
        try? await Task.sleep(for: .seconds(3600))
        return []
      }
    }
  }

  extension HouseholdMembersModel {
    /// Members for previews, loaded from `PreviewHouseholdStore` for `SignedInUser.preview`.
    static func preview(_ outcome: PreviewHouseholdStore.Outcome = .loads(.preview))
      -> HouseholdMembersModel
    {
      HouseholdMembersModel(
        store: PreviewHouseholdStore(outcome: outcome),
        signedInAccountID: SignedInUser.preview.id
      )
    }
  }
#endif
