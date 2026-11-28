import Foundation

/// The app's four tabs.
nonisolated public enum AppTab: Hashable, CaseIterable, Sendable {
  case today, pets, calendar, settings

  public var title: String {
    switch self {
    case .today: "Today"
    case .pets: "Pets"
    case .calendar: "Calendar"
    case .settings: "Settings"
    }
  }

  /// The tab's SF Symbol, in outline; the tab bar fills it when selected.
  public var systemImage: String {
    switch self {
    case .today: "house"
    case .pets: "pawprint"
    case .calendar: "calendar"
    case .settings: "gearshape"
    }
  }
}

/// A screen pushed onto a tab's navigation stack. Routes carry IDs, never
/// objects, so each screen loads what it shows.
nonisolated public enum Route: Hashable, Sendable {
  case petOverview(UUID)
  case petDetails(UUID)
  case petEvent(petID: UUID, petEventID: UUID)
}
