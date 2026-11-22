import Foundation
import KiwiDomain
import Testing

@testable import KiwiFeatures

private let household = Household(id: UUID(), alias: "The Burrow")
private let kiwi = Pet(
  id: UUID(), name: "Kiwi", species: .cat, breed: "European shorthair",
  birthDate: BirthDate(year: 2021, month: 4, day: 12))
private let luna = Pet(id: UUID(), name: "Luna", species: .dog)

/// The Pets of `store`, loaded with `pets`.
private func loadedPets(_ pets: [Pet], store: RecordingPetStore? = nil) async -> (
  PetsModel, RecordingPetStore
) {
  let store = store ?? RecordingPetStore(.success(pets))
  let model = PetsModel(store: store)
  await model.load()
  return (model, store)
}

/// The reference's `usePetProfileForm`, `savePetProfile` and selector cases, and the sheet's rules.
@Suite struct PetDetailsFormTests {
  @Test func validatesAndSubmitsPetDetailsFormValues() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = " Miso "
    form.species = .dog
    form.birthDate = BirthDate(year: 2020, month: 3, day: 5)

    await form.save()

    #expect(
      store.saves == [
        .add(
          PetDetails(
            name: "Miso", species: .dog, birthDate: BirthDate(year: 2020, month: 3, day: 5)),
          to: household.id)
      ])
    #expect(!form.isOpen)
  }

  @Test func addsANewPetToTheHouseholdAsOneRecord() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = " Murri "
    form.breed = "  "

    await form.save()

    #expect(store.saves == [.add(PetDetails(name: "Murri", species: .cat), to: household.id)])
    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Kiwi", "Murri"])
  }

  @Test func refusesToEditAPetThatIsNoLongerInTheList() async {
    let (pets, store) = await loadedPets([luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)

    await form.save()

    #expect(store.saves.isEmpty)
    #expect(form.isOpen)
    #expect(form.failure == .notUpdated)
    #expect(pets.state == .ready([luna]))
  }

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

  @Test func opensTheExistingPetsDetailsFromThePetSelectorCard() async {
    let (pets, _) = await loadedPets([kiwi, luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)

    #expect(form.editing == kiwi.id)
    #expect(form.name == "Kiwi")
    #expect(form.species == .cat)
    #expect(form.breed == "European shorthair")
    #expect(form.birthDate == BirthDate(year: 2021, month: 4, day: 12))
  }

  @Test func opensEmptyWithCatWhenAdding() async {
    let (pets, _) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id)

    #expect(form.editing == nil)
    #expect(form.name.isEmpty && form.breed.isEmpty && form.birthDate == nil)
    #expect(form.species == .cat)
  }

  @Test(arguments: ["", "   "])
  func cannotSaveWithoutAName(name: String) async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = name

    #expect(!form.canSave)
    await form.save()
    #expect(store.saves.isEmpty)
  }

  @Test func cannotSaveADateOfBirthAfterToday() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(
      pets: pets, householdID: household.id, now: { today }, calendar: madrid)
    form.name = "Miso"

    form.birthDate = BirthDate(year: 2026, month: 11, day: 23)
    #expect(!form.canSave)
    await form.save()
    #expect(store.saves.isEmpty)

    form.birthDate = BirthDate(year: 2026, month: 11, day: 22)
    #expect(form.canSave)
    form.birthDate = nil
    #expect(form.canSave)
  }

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

  @Test func clearsABreedAndADateOfBirth() async {
    let (pets, store) = await loadedPets([kiwi])
    let form = PetDetailsForm(pets: pets, householdID: household.id, editing: kiwi)
    form.breed = ""
    form.birthDate = nil

    await form.save()

    #expect(store.saves == [.update(kiwi.id, PetDetails(name: "Kiwi", species: .cat))])
    #expect(pets.state == .ready([Pet(id: kiwi.id, name: "Kiwi", species: .cat)]))
  }

  @Test func addsAPetInNameOrderKeepingTheSelection() async {
    let (pets, _) = await loadedPets([kiwi, luna])
    let form = PetDetailsForm(pets: pets, householdID: household.id)
    form.name = "Archie"

    await form.save()

    guard case .ready(let loaded) = pets.state else { Issue.record("Pets not ready"); return }
    #expect(loaded.map(\.name) == ["Archie", "Kiwi", "Luna"])
    #expect(selectedPet(luna.id, in: loaded) == luna)
  }

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

nonisolated private let madrid = calendar("Europe/Madrid")
/// Noon on 22 November 2026 in Madrid.
nonisolated private let today = Date(timeIntervalSince1970: 1_795_345_200)

nonisolated private func calendar(_ timeZone: String) -> Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: timeZone) ?? .gmt
  return calendar
}
