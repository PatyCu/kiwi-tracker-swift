import Foundation
import KiwiDomain
import Testing

@testable import KiwiFeatures

/// The reference's `TodayScreen` cases ported so far, against the screen's copy.
@Suite struct TodayScreenTests {
  @Test func namesTheHouseholdInTheHeaderOnceItsAliasLoads() {
    #expect(todayTitle(for: Household(id: UUID(), alias: "The Burrow")) == "Today in The Burrow")
  }
}
