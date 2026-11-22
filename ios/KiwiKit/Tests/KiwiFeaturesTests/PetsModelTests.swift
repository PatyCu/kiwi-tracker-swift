import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let kiwi = Pet(id: UUID(), name: "Kiwi", species: .cat)
private let luna = Pet(id: UUID(), name: "Luna", species: .dog)

@Suite struct PetsModelTests {
  @Test func loadsTheHouseholdsPets() async {
    let model = PetsModel(store: RecordingPetStore(.success([kiwi, luna])))

    #expect(model.state == .loading)
    await model.load()
    #expect(model.state == .ready([kiwi, luna]))
  }

  @Test func failsWhenThePetsCannotLoad() async {
    let model = PetsModel(store: RecordingPetStore(.failure(.couldNotLoad)))

    await model.load()

    #expect(model.state == .failed)
  }

  @Test func failsWhenAStoredPetIsInvalid() async {
    let model = PetsModel(store: RecordingPetStore(.failure(.invalidData)))

    await model.load()

    #expect(model.state == .failed)
  }

  @Test func loadsAgainOnRetry() async {
    let model = PetsModel(
      store: RecordingPetStore(.failure(.couldNotLoad), .success([kiwi])))
    await model.load()
    #expect(model.state == .failed)

    await model.load()

    #expect(model.state == .ready([kiwi]))
  }

  @Test func showsLoadingAgainWhileARetryRuns() async {
    let states = Mutex<[PetsModel.State]>([])
    let box = ModelBox()
    let model = PetsModel(
      store: RecordingPetStore(.failure(.couldNotLoad), .success([kiwi])) {
        let state = await MainActor.run { box.model?.state }
        if let state { states.withLock { $0.append(state) } }
      }
    )
    box.model = model
    await model.load()

    await model.load()

    #expect(states.withLock { $0 } == [.loading, .loading])
    #expect(model.state == .ready([kiwi]))
  }

  @Test func ignoresAnEarlierLoadThatFinishesLast() async {
    let release = AsyncStream<Void>.makeStream()
    let first = Mutex(true)
    let store = RecordingPetStore(.success([kiwi]), .success([kiwi, luna])) {
      // The first load waits until the second has finished.
      let isFirst = first.withLock { isFirst in
        defer { isFirst = false }
        return isFirst
      }
      if isFirst {
        for await _ in release.stream { break }
      }
    }
    let model = PetsModel(store: store)
    let earlier = Task { await model.load() }
    while store.loads == 0 { await Task.yield() }

    await model.load()
    release.continuation.yield()
    await earlier.value

    #expect(model.state == .ready([kiwi, luna]))
  }
}

@Suite struct PetSelectionTests {
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

/// Lets the store's hook read the model it was made for.
private final class ModelBox {
  var model: PetsModel?
}
