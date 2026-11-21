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

/// Where a `kiwitracker://` URL opens: a tab and the routes pushed on it.
nonisolated public struct AppDestination: Equatable, Sendable {
  public static let urlScheme = "kiwitracker"

  public let tab: AppTab
  public let path: [Route]

  public init(tab: AppTab, path: [Route] = []) {
    self.tab = tab
    self.path = path
  }

  /// Maps the reference app's paths (`src/app/(tabs)`), such as
  /// `kiwitracker://pets/<petID>/profile`, with each parent screen under the
  /// last one so Back works. `nil` for any other URL, which the reference
  /// answers with "Page not found".
  public init?(url: URL) {
    guard url.scheme?.lowercased() == Self.urlScheme else { return nil }
    // In `kiwitracker://pets/<petID>` the first segment is the URL's host.
    let segments = ([url.host(percentEncoded: false) ?? ""] + url.pathComponents)
      .filter { !$0.isEmpty && $0 != "/" }
    let rest = Array(segments.dropFirst())

    switch segments.first {
    case nil:
      self.init(tab: .today)
    case "pets":
      guard let path = Self.petsPath(rest) else { return nil }
      self.init(tab: .pets, path: path)
    case "calendar":
      guard let path = Self.calendarPath(rest) else { return nil }
      self.init(tab: .calendar, path: path)
    case "settings" where rest.isEmpty:
      self.init(tab: .settings)
    default:
      return nil
    }
  }

  private static func petsPath(_ segments: [String]) -> [Route]? {
    guard let first = segments.first else { return [] }
    guard let petID = UUID(uuidString: first) else { return nil }
    let rest = segments.dropFirst()
    if rest.isEmpty { return [.pet(petID)] }
    if Array(rest) == ["profile"] { return [.pet(petID), .petProfile(petID)] }
    guard let recordID = recordID(rest) else { return nil }
    return [.pet(petID), .record(petID: petID, recordID: recordID)]
  }

  private static func calendarPath(_ segments: [String]) -> [Route]? {
    guard let first = segments.first else { return [] }
    guard let petID = UUID(uuidString: first), let recordID = recordID(segments.dropFirst())
    else { return nil }
    return [.record(petID: petID, recordID: recordID)]
  }

  /// The record ID in `records/<recordID>`.
  private static func recordID(_ segments: ArraySlice<String>) -> UUID? {
    guard segments.count == 2, segments.first == "records", let last = segments.last else {
      return nil
    }
    return UUID(uuidString: last)
  }
}
