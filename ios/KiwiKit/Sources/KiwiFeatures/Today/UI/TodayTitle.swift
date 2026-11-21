import KiwiDomain

/// Today's title, naming the Household, as the reference app's `TodayScreen` header. The tabs
/// only open once the Household has loaded, so there is no title without it.
func todayTitle(for household: Household) -> String {
  "Today in \(household.alias)"
}
