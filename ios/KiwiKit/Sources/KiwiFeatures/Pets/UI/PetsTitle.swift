import KiwiDomain

/// Pets' title, naming the Household, as the reference app's `PetsScreen` header. The tabs only
/// open once the Household has loaded, so there is no title without it.
func petsTitle(for household: Household) -> String {
  "Pets in \(household.alias)"
}
