import Foundation
import KiwiDomain
import Observation

/// Adding a Pet or editing its details and photo. Opens empty with Cat, or with the Pet's details
/// and stored photo, nothing picked; closes once the save succeeds, and stays open with what was
/// entered when it fails.
@Observable final class PetDetailsForm {
  /// What failed, so the sheet names it.
  enum Failure: Equatable {
    case notAdded
    case notUpdated
    /// The picked photo couldn't be read; the sheet is left as it was.
    case photoNotSelected
  }

  var name: String
  var species: PetSpecies
  var breed: String
  var birthDate: BirthDate?
  /// Set when a save fails; clearing it dismisses the alert.
  var failure: Failure?
  private(set) var isSaving = false
  /// A picked photo is being prepared; Save waits for it, so the last pick is the one saved.
  private(set) var isPreparingPhoto = false
  private(set) var isOpen = true
  /// The photo picked in this sheet, prepared as it will be stored; `nil` until one is picked.
  /// Only the last one picked is saved.
  private(set) var pickedPhoto: Data?
  /// Set with the saved Pet's name when the details saved but the photo didn't, so the sheet
  /// reports it once it has closed.
  private(set) var photoNotSavedFor: String?

  /// The Pet being edited; `nil` when adding.
  let editing: UUID?
  /// Where the edited Pet's photo is stored; `nil` when adding or when it has none.
  private let storedPhotoPath: String?
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
    storedPhotoPath = pet?.photoPath
    name = pet?.name ?? ""
    species = pet?.species ?? .cat
    breed = pet?.breed ?? ""
    birthDate = pet?.birthDate
    self.now = now
    self.calendar = calendar
  }

  /// The photo the sheet shows: the one picked, or else the Pet's stored photo, if fetched.
  var shownPhoto: Data? {
    pickedPhoto ?? pets.photo(at: storedPhotoPath)
  }

  /// Fetches the edited Pet's stored photo, if it isn't on the device yet.
  func loadStoredPhoto() async {
    await pets.loadPhoto(at: storedPhotoPath)
  }

  /// Prepares the photo picked from the library, `nil` when the picker couldn't hand it over, so
  /// the sheet shows what will be stored. One that can't be read keeps the previous one and
  /// reports it.
  func pickPhoto(_ data: Data?) async {
    isPreparingPhoto = true
    defer { isPreparingPhoto = false }
    // Off the main actor: reading a full-size photo takes a moment.
    let prepared = await Task.detached(priority: .userInitiated) {
      data.flatMap { try? preparedPetPhoto(from: $0) }
    }.value
    if let prepared {
      pickedPhoto = prepared
    } else {
      failure = .photoNotSelected
    }
  }

  /// The details are valid, no other save is running and no picked photo is being prepared.
  var canSave: Bool {
    !isSaving && !isPreparingPhoto && details.isValid(now: now(), calendar: calendar)
  }

  func save() async {
    guard canSave else { return }
    let details = details.normalized()
    isSaving = true
    defer { isSaving = false }
    do {
      let result = try await pets.save(
        details, photo: pickedPhoto, editing: editing, householdID: householdID)
      if result == .photoNotSaved { photoNotSavedFor = details.name }
      isOpen = false
    } catch {
      failure = editing == nil ? .notAdded : .notUpdated
    }
  }

  private var details: PetDetails {
    PetDetails(name: name, species: species, breed: breed, birthDate: birthDate)
  }
}
