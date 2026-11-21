import Foundation
import Observation

/// The selected tab and each stack's path. Today and Settings push nothing, so
/// only Pets and Calendar have a path.
@Observable
public final class AppNavigation {
  public var selectedTab: AppTab
  public var petsPath: [Route]
  public var calendarPath: [Route]
  /// Set when a `kiwitracker://` URL matches no screen.
  public var showsPageNotFound = false

  public init(selectedTab: AppTab = .today, petsPath: [Route] = [], calendarPath: [Route] = []) {
    self.selectedTab = selectedTab
    self.petsPath = petsPath
    self.calendarPath = calendarPath
  }

  /// Shows the URL's tab with its routes, replacing that tab's stack.
  public func open(_ url: URL) {
    guard let destination = AppDestination(url: url) else {
      showsPageNotFound = true
      return
    }
    showsPageNotFound = false
    selectedTab = destination.tab
    switch destination.tab {
    case .pets: petsPath = destination.path
    case .calendar: calendarPath = destination.path
    case .today, .settings: break
    }
  }

  public func returnToToday() {
    showsPageNotFound = false
    selectedTab = .today
  }
}
