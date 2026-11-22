import Foundation
import Observation

/// The selected tab and each stack's path. Today and Settings push nothing, so
/// only Pets and Calendar have a path.
@Observable
public final class AppNavigation {
  public var selectedTab: AppTab
  public var petsPath: [Route]
  public var calendarPath: [Route]

  public init(selectedTab: AppTab = .today, petsPath: [Route] = [], calendarPath: [Route] = []) {
    self.selectedTab = selectedTab
    self.petsPath = petsPath
    self.calendarPath = calendarPath
  }
}
