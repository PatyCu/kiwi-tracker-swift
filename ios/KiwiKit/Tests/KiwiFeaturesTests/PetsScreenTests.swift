import Foundation
import KiwiDomain
import Testing

@testable import KiwiFeatures

/// The reference's `PetsScreen` cases ported so far, against the screen's copy.
@Suite struct PetsScreenTests {
  @Test func namesTheHouseholdInTheHeaderOnceItsAliasLoads() {
    #expect(petsTitle(for: Household(id: UUID(), alias: "The Burrow")) == "Pets in The Burrow")
  }
}
