import Foundation
import KiwiDomain
import Testing

@testable import KiwiFeatures

private let kiwi = Pet(id: UUID(), name: "Kiwi", species: .cat)
private let luna = Pet(id: UUID(), name: "Luna", species: .dog)

@Suite struct SelectedPetTests {
  @Test func selectsTheFirstPetByDefault() {
    #expect(selectedPet(nil, in: [kiwi, luna]) == kiwi)
  }

  @Test func keepsTheSelectedPet() {
    #expect(selectedPet(luna.id, in: [kiwi, luna]) == luna)
  }

  @Test func fallsBackToTheFirstPetWhenTheSelectedOneIsGone() {
    #expect(selectedPet(UUID(), in: [kiwi, luna]) == kiwi)
  }

  @Test func selectsNothingWithoutPets() {
    #expect(selectedPet(luna.id, in: []) == nil)
  }
}
