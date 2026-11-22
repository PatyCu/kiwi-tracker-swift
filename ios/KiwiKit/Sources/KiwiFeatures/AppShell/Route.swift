import Foundation

/// The app's four tabs, as the reference app's `(tabs)` layout.
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

  /// The SF Symbol matching the reference's Ionicon; the tab bar fills it when selected.
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
  case pet(UUID)
  case petProfile(UUID)
  case record(petID: UUID, recordID: UUID)
}
