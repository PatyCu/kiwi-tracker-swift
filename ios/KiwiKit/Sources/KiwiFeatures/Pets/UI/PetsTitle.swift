import KiwiDomain

/// Pets' title, naming the Household, as the reference app's `PetsScreen` header.
func petsTitle(for household: Household) -> String {
  "Pets in \(household.alias)"
}
