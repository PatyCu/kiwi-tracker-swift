import Foundation
import Testing

@testable import KiwiFeatures

nonisolated private let petID = UUID()
nonisolated private let recordID = UUID()

private func url(_ string: String) throws -> URL {
  try #require(URL(string: string))
}

@Suite struct AppDestinationTests {
  @Test(arguments: ["kiwitracker://", "kiwitracker:///", "KIWITRACKER://"])
  func opensTodayForTheBareScheme(_ string: String) throws {
    #expect(AppDestination(url: try url(string)) == AppDestination(tab: .today))
  }

  @Test(arguments: [
    ("kiwitracker://pets", AppTab.pets),
    ("kiwitracker:///pets/", .pets),
    ("kiwitracker://calendar", .calendar),
    ("kiwitracker://settings", .settings),
  ])
  func opensATabAtItsRoot(_ string: String, tab: AppTab) throws {
    #expect(AppDestination(url: try url(string)) == AppDestination(tab: tab))
  }

  @Test func opensAPet() throws {
    let destination = AppDestination(url: try url("kiwitracker://pets/\(petID)"))
    #expect(destination == AppDestination(tab: .pets, path: [.pet(petID)]))
  }

  @Test func opensAPetProfileAboveItsPet() throws {
    let destination = AppDestination(url: try url("kiwitracker://pets/\(petID)/profile"))
    #expect(destination == AppDestination(tab: .pets, path: [.pet(petID), .petProfile(petID)]))
  }

  @Test func opensAPetRecordAboveItsPet() throws {
    let destination = AppDestination(
      url: try url("kiwitracker://pets/\(petID)/records/\(recordID)")
    )
    #expect(
      destination
        == AppDestination(
          tab: .pets,
          path: [.pet(petID), .record(petID: petID, recordID: recordID)]
        )
    )
  }

  @Test func opensACalendarRecordInTheCalendarTab() throws {
    let destination = AppDestination(
      url: try url("kiwitracker://calendar/\(petID)/records/\(recordID)")
    )
    #expect(
      destination
        == AppDestination(tab: .calendar, path: [.record(petID: petID, recordID: recordID)])
    )
  }

  @Test(arguments: [
    "https://pets",
    "kiwitracker://unknown",
    "kiwitracker://pets/not-a-uuid",
    "kiwitracker://pets/\(petID)/photos",
    "kiwitracker://pets/\(petID)/records",
    "kiwitracker://pets/\(petID)/records/not-a-uuid",
    "kiwitracker://calendar/\(petID)",
    "kiwitracker://settings/more",
  ])
  func findsNoScreenForAnyOtherURL(_ string: String) throws {
    #expect(AppDestination(url: try url(string)) == nil)
  }
}

@Suite struct AppNavigationTests {
  @Test func openingAURLSelectsItsTabAndReplacesItsPath() throws {
    let navigation = AppNavigation(petsPath: [.pet(UUID())])

    navigation.open(try url("kiwitracker://pets/\(petID)/profile"))

    #expect(navigation.selectedTab == .pets)
    #expect(navigation.petsPath == [.pet(petID), .petProfile(petID)])
  }

  @Test func openingATabRootPopsItsStack() throws {
    let navigation = AppNavigation(calendarPath: [.record(petID: petID, recordID: recordID)])

    navigation.open(try url("kiwitracker://calendar"))

    #expect(navigation.selectedTab == .calendar)
    #expect(navigation.calendarPath.isEmpty)
  }

  @Test func anUnknownURLShowsPageNotFoundAndReturnsToToday() throws {
    let navigation = AppNavigation(selectedTab: .settings)

    navigation.open(try url("kiwitracker://unknown"))

    #expect(navigation.showsPageNotFound)
    #expect(navigation.selectedTab == .settings)

    navigation.returnToToday()

    #expect(!navigation.showsPageNotFound)
    #expect(navigation.selectedTab == .today)
  }

  @Test func aKnownURLDismissesPageNotFound() throws {
    let navigation = AppNavigation()
    navigation.open(try url("kiwitracker://unknown"))

    navigation.open(try url("kiwitracker://settings"))

    #expect(!navigation.showsPageNotFound)
    #expect(navigation.selectedTab == .settings)
  }
}
