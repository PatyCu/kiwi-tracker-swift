import KiwiDomain

/// Today's title, naming the Household, as the reference app's `TodayScreen` header.
func todayTitle(for household: Household) -> String {
  "Today in \(household.alias)"
}
