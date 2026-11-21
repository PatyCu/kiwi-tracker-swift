#if DEBUG
  import Foundation
  import KiwiDomain

  extension Household {
    nonisolated static let preview = Household(id: UUID(), alias: "The Burrow")
  }

  /// The Household for previews: loads one, finds none, fails, or never finishes.
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
  }
#endif
