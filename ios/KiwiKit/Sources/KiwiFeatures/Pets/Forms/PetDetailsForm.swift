import Foundation
import KiwiDomain
import Observation

/// Adding a Pet or editing its details. Opens empty with Cat, or with the Pet's details; closes
/// once the save succeeds, and stays open with what was entered when it fails.
@Observable final class PetDetailsForm {
  /// Which save failed, so the sheet names it.
  enum Failure: Equatable {
    case notAdded
    case notUpdated
  }

  var name: String
  var species: PetSpecies
  var breed: String
  var birthDate: BirthDate?
  /// Set when a save fails; clearing it dismisses the alert.
  var failure: Failure?
  private(set) var isSaving = false
  private(set) var isOpen = true

  /// The Pet being edited; `nil` when adding.
  let editing: UUID?
  private let pets: PetsModel
  private let householdID: UUID
  private let now: () -> Date
  private let calendar: Calendar

  init(
    pets: PetsModel,
    householdID: UUID,
    editing pet: Pet? = nil,
    now: @escaping () -> Date = { .now },
    calendar: Calendar = .current
  ) {
    self.pets = pets
    self.householdID = householdID
    editing = pet?.id
    name = pet?.name ?? ""
    species = pet?.species ?? .cat
    breed = pet?.breed ?? ""
    birthDate = pet?.birthDate
    self.now = now
    self.calendar = calendar
  }

  /// The details are valid and no other save is running.
  var canSave: Bool {
    !isSaving && details.isValid(now: now(), calendar: calendar)
  }

  func save() async {
    guard canSave else { return }
    let details = details.normalized()
    isSaving = true
    defer { isSaving = false }
    do {
      try await pets.save(details, editing: editing, householdID: householdID)
      isOpen = false
    } catch {
      failure = editing == nil ? .notAdded : .notUpdated
    }
  }

  private var details: PetDetails {
    PetDetails(name: name, species: species, breed: breed, birthDate: birthDate)
  }
}
