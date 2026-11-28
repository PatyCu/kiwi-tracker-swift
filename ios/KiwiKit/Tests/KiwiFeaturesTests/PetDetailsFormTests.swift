import Foundation
import ImageIO
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let household = Household(id: UUID(), alias: "The Burrow")
private let kiwi = Pet(
  id: UUID(), name: "Kiwi", species: .cat, breed: "European shorthair",
  birthDate: BirthDate(year: 2021, month: 4, day: 12))
private let luna = Pet(id: UUID(), name: "Luna", species: .dog)

/// Kiwi with a stored photo, at `oldPhoto`.
private let kiwiWithPhoto = Pet(
  id: kiwi.id, name: "Kiwi", species: .cat, breed: kiwi.breed, birthDate: kiwi.birthDate,
  photoPath: oldPhoto)
nonisolated private let oldPhoto = "kiwi/old.jpg"
nonisolated private let storedPhoto = Data("stored photo".utf8)

/// The Pets of `store`, loaded with `pets`, with their photos in `photos`.
private func loadedPets(
  _ pets: [Pet], store: RecordingPetStore? = nil, photos: RecordingPetPhotoStore? = nil
) async -> (PetsModel, RecordingPetStore) {
  let store = store ?? RecordingPetStore(.success(pets))
  let model = PetsModel(store: store, photos: photos ?? RecordingPetPhotoStore())
  await model.load()
  return (model, store)
}

/// The loaded Pet named `name`.
private func pet(named name: String, in pets: PetsModel) -> Pet? {
  guard case .ready(let loaded) = pets.state else { return nil }
  return loaded.first { $0.name == name }
}

@Suite struct PetDetailsFormTests {
  // Covers: PET-031
  @Test func addsANewPetToTheHouseholdAsOneRecord() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = " Murri "
    form.species = .dog
    form.breed = "  "
    form.birthDate = BirthDate(year: 2020, month: 3, day: 5)

    await form.save()

    #expect(
      store.saves == [
        .add(
          PetDetails(
            name: "Murri", species: .dog, birthDate: BirthDate(year: 2020, month: 3, day: 5)),
          to: household.id)
      ])
    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Kiwi", "Murri"])
    #expect(!form.isOpen)
  }

  // Covers: PET-030
  @Test func refusesToEditAPetThatIsNoLongerInTheList() async {
    let (pets, store) = await loadedPets([luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)

    await form.save()

    #expect(store.saves.isEmpty)
    #expect(form.isOpen)
    #expect(form.failure == .notUpdated)
    #expect(pets.state == .ready([luna]))
  }

  // Covers: PET-028
  @Test func addsTheFirstPetFromTheEmptyStateWhenTheHouseholdHasNoneYet() async {
    let (pets, _) = await loadedPets([])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    form.species = .dog

    await form.save()

    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Miso"])
    #expect(selectedPet(nil, in: loaded)?.name == "Miso")
  }

  // Covers: PET-016, PET-018
  @Test func opensWithThePetsDetailsWhenEditing() async {
    let (pets, _) = await loadedPets([kiwi, luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)

    #expect(form.editing == kiwi.id)
    #expect(form.name == "Kiwi")
    #expect(form.species == .cat)
    #expect(form.breed == "European shorthair")
    #expect(form.birthDate == BirthDate(year: 2021, month: 4, day: 12))
  }

  /// The invalid cases live in `PetDetailsTests`. A date after the form's today shows the form
  /// checks against the clock and calendar it was given.
  // Covers: PET-019, PET-023
  @Test func blocksSaveWhileTheDetailsAreInvalid() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(
      pets: pets, householdID: household.id, now: { today }, calendar: madrid)
    form.name = "Miso"
    form.birthDate = BirthDate(year: 2026, month: 11, day: 23)

    #expect(!form.canSave)
    await form.save()
    #expect(store.saves.isEmpty)
    #expect(form.isOpen)

    form.birthDate = BirthDate(year: 2026, month: 11, day: 22)
    #expect(form.canSave)
  }

  // Covers: PET-027
  @Test func editsAPetAndKeepsItInNameOrder() async {
    let (pets, store) = await loadedPets([kiwi, luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: luna)
    form.name = "Archie"

    await form.save()

    #expect(store.saves == [.update(luna.id, PetDetails(name: "Archie", species: .dog))])
    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Archie", "Kiwi"])
    #expect(loaded.map(\.id) == [luna.id, kiwi.id])
    #expect(!form.isOpen)
  }

  // Covers: PET-021, PET-022
  @Test func clearsABreedAndADateOfBirth() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)
    form.breed = ""
    form.birthDate = nil

    await form.save()

    #expect(store.saves == [.update(kiwi.id, PetDetails(name: "Kiwi", species: .cat))])
    #expect(pets.state == .ready([Pet(id: kiwi.id, name: "Kiwi", species: .cat)]))
  }

  // Covers: PET-027
  @Test func addsAPetInNameOrderKeepingTheSelection() async {
    let (pets, _) = await loadedPets([kiwi, luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Archie"

    await form.save()

    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Archie", "Kiwi", "Luna"])
    #expect(selectedPet(luna.id, in: loaded) == luna)
  }

  // Covers: PET-029
  @Test func keepsTheFormOpenWithItsInputWhenAnAddFails() async {
    let store = RecordingPetStore(.success([kiwi]))
    store.saveFails = true
    let (pets, _) = await loadedPets([kiwi], store: store)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    form.breed = "Tabby"

    await form.save()

    #expect(form.isOpen)
    #expect(form.failure == .notAdded)
    #expect(form.name == "Miso" && form.breed == "Tabby")
    #expect(!form.isSaving)
    #expect(pets.state == .ready([kiwi]))
  }

  // Covers: PET-029
  @Test func saysTheUpdateFailedWhenAnEditFails() async {
    let store = RecordingPetStore(.success([kiwi]))
    store.saveFails = true
    let (pets, _) = await loadedPets([kiwi], store: store)
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)
    form.name = "Mochi"

    await form.save()

    #expect(form.isOpen)
    #expect(form.failure == .notUpdated)
    #expect(form.name == "Mochi")
    #expect(pets.state == .ready([kiwi]))
  }

  // Covers: PET-025
  @Test func savesNothingMoreWhileASaveRuns() async {
    let release = AsyncStream<Void>.makeStream()
    let store = RecordingPetStore(.success([kiwi])) {
    } whileSaving: {
      for await _ in release.stream { break }
    }
    let (pets, _) = await loadedPets([kiwi], store: store)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    let first = Task { await form.save() }
    while store.saves.isEmpty { await Task.yield() }

    #expect(form.isSaving)
    #expect(!form.canSave)
    await form.save()
    release.continuation.yield()
    await first.value

    #expect(store.saves.count == 1)
    #expect(!form.isOpen)
  }
}

@Suite struct PetDetailsFormPhotoTests {
  // Covers: PHOTO-012
  @Test func uploadsANewPetsPhotoAfterAddingItAndRecordsWhereItIsStored() async throws {
    let photos = RecordingPetPhotoStore()
    let (pets, store) = await loadedPets([], photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    await form.pickPhoto(testPhoto(width: 900, height: 900))
    let picked = try #require(form.pickedPhoto)

    await form.save()

    let miso = try #require(pet(named: "Miso", in: pets))
    #expect(photos.uploads == [miso.id])
    #expect(
      store.saves == [
        .add(PetDetails(name: "Miso", species: .cat), to: household.id),
        .photoPath("\(miso.id)/1.jpg", of: miso.id),
      ])
    #expect(photos.files["\(miso.id)/1.jpg"] == picked)
    #expect(photos.removals.isEmpty)
    #expect(miso.photoPath == "\(miso.id)/1.jpg")
    #expect(form.photoNotSavedFor == nil)
    #expect(!form.isOpen)
  }

  // Covers: PHOTO-020
  @Test func showsAPhotoJustSavedWithoutFetchingIt() async throws {
    let photos = RecordingPetPhotoStore()
    let (pets, _) = await loadedPets([], photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    let miso = try #require(pet(named: "Miso", in: pets))
    await pets.loadPhoto(at: miso.photoPath)
    #expect(pets.photo(at: miso.photoPath) == form.pickedPhoto)
    #expect(photos.fetches.isEmpty)
  }

  // Covers: PHOTO-017
  @Test func pointsThePetAtItsNewPhotoBeforeDeletingTheFileItReplaces() async throws {
    let store = RecordingPetStore(.success([kiwiWithPhoto]))
    let pointedFirst = Mutex<Bool?>(nil)
    let pointing = RecordingPetStore.Save.photoPath("\(kiwi.id)/1.jpg", of: kiwi.id)
    let photos = RecordingPetPhotoStore([oldPhoto: storedPhoto]) { path in
      guard path == oldPhoto else { return }
      pointedFirst.withLock { $0 = store.saves.contains(pointing) }
    }
    let (pets, _) = await loadedPets([kiwiWithPhoto], store: store, photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    #expect(photos.removals == [oldPhoto])
    #expect(pointedFirst.withLock { $0 } == true)
    #expect(pet(named: "Kiwi", in: pets)?.photoPath == "\(kiwi.id)/1.jpg")
    #expect(form.photoNotSavedFor == nil)
  }

  // Covers: PHOTO-015
  @Test func keepsTheShownPhotoWhenTheDetailsAreSavedWithoutANewPhoto() async throws {
    let photos = RecordingPetPhotoStore([oldPhoto: storedPhoto])
    let (pets, store) = await loadedPets([kiwiWithPhoto], photos: photos)
    await pets.loadPhoto(at: kiwiWithPhoto.photoPath)
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    form.name = "Kiwi II"

    await form.save()

    let saved = try #require(pet(named: "Kiwi II", in: pets))
    #expect(saved.photoPath == oldPhoto)
    #expect(pets.photo(at: saved.photoPath) == storedPhoto)
    #expect(photos.uploads.isEmpty)
    #expect(store.saves.count == 1)
  }

  // Covers: PHOTO-013
  @Test func doesNotUploadThePhotoWhenTheDetailsAreNotSaved() async {
    let store = RecordingPetStore(.success([]))
    store.saveFails = true
    let photos = RecordingPetPhotoStore()
    let (pets, _) = await loadedPets([], store: store, photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    #expect(photos.uploads.isEmpty)
    #expect(form.failure == .notAdded)
    #expect(form.isOpen)
    #expect(form.pickedPhoto != nil)
  }

  // Covers: PHOTO-014
  @Test func returnsTheSavedPetWhenOnlyItsPhotoFailsSoItIsNeverAddedTwice() async throws {
    let photos = RecordingPetPhotoStore()
    photos.fail(.couldNotUpload)
    let (pets, store) = await loadedPets([], photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = " Miso "
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    let miso = try #require(pet(named: "Miso", in: pets))
    #expect(miso.photoPath == nil)
    #expect(store.saves == [.add(PetDetails(name: "Miso", species: .cat), to: household.id)])
    #expect(!form.isOpen)
    #expect(form.failure == nil)
    #expect(form.photoNotSavedFor == "Miso")
  }

  // Covers: PHOTO-016
  @Test func keepsThePreviousPhotoAndDeletesTheNewFileWhenThePetCannotPointToIt() async {
    let store = RecordingPetStore(.success([kiwiWithPhoto]))
    store.photoPathFails = true
    let photos = RecordingPetPhotoStore([oldPhoto: storedPhoto])
    let (pets, _) = await loadedPets([kiwiWithPhoto], store: store, photos: photos)
    await pets.loadPhoto(at: kiwiWithPhoto.photoPath)
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    #expect(photos.removals == ["\(kiwi.id)/1.jpg"])
    #expect(pets.state == .ready([kiwiWithPhoto]))
    #expect(pets.photo(at: kiwiWithPhoto.photoPath) == storedPhoto)
    #expect(form.photoNotSavedFor == "Kiwi")
    #expect(!form.isOpen)
  }

  // Covers: PHOTO-018
  @Test func stillSavesTheNewPhotoWhenTheReplacedFileCannotBeDeleted() async {
    let photos = RecordingPetPhotoStore([oldPhoto: storedPhoto])
    photos.fail(.couldNotRemove)
    let (pets, _) = await loadedPets([kiwiWithPhoto], photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    await form.pickPhoto(testPhoto(width: 900, height: 900))

    await form.save()

    #expect(pet(named: "Kiwi", in: pets)?.photoPath == "\(kiwi.id)/1.jpg")
    #expect(form.photoNotSavedFor == nil)
    #expect(!form.isOpen)
  }

  // Covers: PHOTO-004, PHOTO-006
  @Test func showsThePickedPhotoAsStoredAndSavesOnlyTheLastOne() async throws {
    let photos = RecordingPetPhotoStore()
    let (pets, _) = await loadedPets([], photos: photos)
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Miso"

    await form.pickPhoto(testPhoto(width: 300, height: 300))
    let first = try #require(form.shownPhoto)
    await form.pickPhoto(testPhoto(width: 3000, height: 4000))
    let last = try #require(form.shownPhoto)
    await form.save()

    #expect(imageProperties(of: first)[kCGImagePropertyPixelWidth] as? Int == 300)
    #expect(imageProperties(of: last)[kCGImagePropertyPixelWidth] as? Int == 512)
    #expect(photos.files.values.map { $0 } == [last])
  }

  // Covers: PHOTO-005
  @Test(arguments: [Data("not a photo".utf8), nil])
  func reportsAPhotoThatCannotBeReadAndKeepsTheSheetAsItWas(data: Data?) async throws {
    let (pets, _) = await loadedPets([])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    await form.pickPhoto(testPhoto(width: 900, height: 900))
    let picked = try #require(form.pickedPhoto)

    await form.pickPhoto(data)

    #expect(form.failure == .photoNotSelected)
    #expect(form.pickedPhoto == picked)
    #expect(form.isOpen)
  }

  // Covers: PHOTO-007
  @Test func opensWithTheStoredPhotoAndNothingPickedAfterACancelledPick() async {
    let photos = RecordingPetPhotoStore([oldPhoto: storedPhoto])
    let (pets, _) = await loadedPets([kiwiWithPhoto], photos: photos)
    let cancelled = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    await cancelled.loadStoredPhoto()
    await cancelled.pickPhoto(testPhoto(width: 900, height: 900))

    let reopened = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwiWithPhoto)
    await reopened.loadStoredPhoto()

    #expect(reopened.pickedPhoto == nil)
    #expect(reopened.shownPhoto == storedPhoto)
    #expect(photos.uploads.isEmpty)
  }
}

nonisolated private let madrid = calendar("Europe/Madrid")
/// Noon on 22 November 2026 in Madrid.
nonisolated private let today = Date(timeIntervalSince1970: 1_795_345_200)

nonisolated private func calendar(_ timeZone: String) -> Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: timeZone) ?? .gmt
  return calendar
}
