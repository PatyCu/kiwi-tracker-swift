import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiFeatures

private let kiwi = Pet(id: UUID(), name: "Kiwi", species: .cat)
private let luna = Pet(id: UUID(), name: "Luna", species: .dog)

@Suite struct PetsModelTests {
  // Covers: PET-001
  @Test func loadsTheHouseholdsPets() async {
    let model = PetsModel(
      store: RecordingPetStore(.success([kiwi, luna])), photos: RecordingPetPhotoStore())

    #expect(model.state == .loading)
    await model.load()
    #expect(model.state == .ready([kiwi, luna]))
  }

  // Covers: PET-007
  @Test(arguments: [PetStoreError.couldNotLoad, .invalidData])
  func failsWhenThePetsCannotLoad(error: PetStoreError) async {
    let model = PetsModel(
      store: RecordingPetStore(.failure(error)), photos: RecordingPetPhotoStore())

    await model.load()

    #expect(model.state == .failed)
  }

  // Covers: PET-007
  @Test func loadsAgainOnRetry() async {
    let model = PetsModel(
      store: RecordingPetStore(.failure(.couldNotLoad), .success([kiwi])),
      photos: RecordingPetPhotoStore())
    await model.load()
    #expect(model.state == .failed)

    await model.load()

    #expect(model.state == .ready([kiwi]))
  }

  // Covers: PET-007
  @Test func showsLoadingAgainWhileARetryRuns() async {
    let states = Mutex<[PetsModel.State]>([])
    let box = ModelBox()
    let model = PetsModel(
      store: RecordingPetStore(.failure(.couldNotLoad), .success([kiwi])) {
        let state = await MainActor.run { box.model?.state }
        if let state { states.withLock { $0.append(state) } }
      },
      photos: RecordingPetPhotoStore()
    )
    box.model = model
    await model.load()

    await model.load()

    #expect(states.withLock { $0 } == [.loading, .loading])
    #expect(model.state == .ready([kiwi]))
  }

  // Covers: PET-008
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
    let model = PetsModel(store: store, photos: RecordingPetPhotoStore())
    let earlier = Task { await model.load() }
    while store.loads == 0 { await Task.yield() }

    await model.load()
    release.continuation.yield()
    await earlier.value

    #expect(model.state == .ready([kiwi, luna]))
  }

  // Covers: PHOTO-021
  @Test func showsAPhotoFetchedOnceWithoutFetchingItAgain() async {
    let photo = Data("kiwi photo".utf8)
    let kiwi = Pet(id: UUID(), name: "Kiwi", species: .cat, photoPath: "kiwi/1.jpg")
    let photos = RecordingPetPhotoStore(["kiwi/1.jpg": photo])
    let model = PetsModel(store: RecordingPetStore(.success([kiwi, luna])), photos: photos)
    await model.load()

    await model.loadPhoto(at: kiwi.photoPath)
    await model.loadPhoto(at: kiwi.photoPath)
    await model.loadPhoto(at: luna.photoPath)

    #expect(model.photo(at: kiwi.photoPath) == photo)
    #expect(model.photo(at: luna.photoPath) == nil)
    #expect(photos.fetches == ["kiwi/1.jpg"])
  }

  // Covers: PHOTO-023
  @Test func showsThePawWhenAPhotoCannotBeFetchedAndTriesAgainNextTime() async {
    let photo = Data("kiwi photo".utf8)
    let kiwi = Pet(id: UUID(), name: "Kiwi", species: .cat, photoPath: "kiwi/1.jpg")
    let photos = RecordingPetPhotoStore(["kiwi/1.jpg": photo])
    photos.fail(.couldNotFetch)
    let model = PetsModel(store: RecordingPetStore(.success([kiwi])), photos: photos)
    await model.load()

    await model.loadPhoto(at: kiwi.photoPath)
    #expect(model.photo(at: kiwi.photoPath) == nil)
    #expect(model.state == .ready([kiwi]))

    photos.fail(.couldNotFetch, false)
    await model.loadPhoto(at: kiwi.photoPath)
    #expect(model.photo(at: kiwi.photoPath) == photo)
  }
}

/// Lets the store's hook read the model it was made for.
private final class ModelBox {
  var model: PetsModel?
}
