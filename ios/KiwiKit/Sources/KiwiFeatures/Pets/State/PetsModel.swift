import Foundation
import KiwiDomain
import Observation

/// The signed-in Account's Household's Pets and their photos: loads them and saves a Member's
/// changes. One model per sign-in, so a new Account never sees the previous Pets.
@Observable final class PetsModel {
  enum State: Equatable {
    case loading
    case ready([Pet])
    case failed
  }

  /// What a save stored besides the details.
  enum SaveResult: Equatable {
    /// The details, and the new photo if one was given.
    case saved
    /// The details only: the new photo couldn't be stored, so the Pet keeps its previous one.
    case photoNotSaved
  }

  private(set) var state = State.loading
  /// The photos fetched or saved during this sign-in, by path.
  private var photos: [String: Data] = [:]
  private let store: any PetStore
  private let photoStore: any PetPhotoStore
  private var attempt = 0

  init(store: any PetStore, photos: any PetPhotoStore) {
    self.store = store
    photoStore = photos
  }

  /// Loads the Pets, showing loading while it runs. Calling it again is Retry.
  func load() async {
    attempt += 1
    let current = attempt
    state = .loading
    let next: State
    do {
      next = .ready(try await store.loadPets())
    } catch {
      next = .failed
    }
    // Only the latest load decides, so an earlier one finishing late never shows stale data.
    if current == attempt { state = next }
  }

  /// Adds a Pet with `details` to the Household with `householdID`, or, with `editing`, saves them
  /// to that Pet. The stored Pet goes into the list in name order at once, leaving the selection as
  /// it is. Saving needs the Pets loaded, and editing a Pet no longer in the list fails without
  /// saving, so the wrong Pet is never recreated or overwritten.
  ///
  /// With `photo`, a prepared JPEG, the photo is stored after the details, since storage only
  /// accepts photos of existing Pets, and shows at once. It throws only when the details fail, so
  /// a Pet whose photo failed is never added twice.
  @discardableResult
  func save(_ details: PetDetails, photo: Data? = nil, editing: UUID?, householdID: UUID)
    async throws(PetStoreError) -> SaveResult
  {
    guard case .ready(let pets) = state else { throw .couldNotSave }
    var stored: Pet
    if let editing {
      guard pets.contains(where: { $0.id == editing }) else { throw .couldNotSave }
      stored = try await store.updatePet(editing, details)
    } else {
      stored = try await store.addPet(details, to: householdID)
    }
    var result = SaveResult.saved
    if let photo {
      if let withPhoto = await savePhoto(photo, of: stored.id, replacing: stored.photoPath) {
        stored = withPhoto
      } else {
        result = .photoNotSaved
      }
    }
    // A load that started meanwhile replaces the list anyway, and shows this Pet.
    if case .ready(let current) = state {
      state = .ready((current.filter { $0.id != stored.id } + [stored]).sorted(by: nameOrder))
    }
    return result
  }

  /// The photo at a Pet's `photoPath`, if fetched or saved during this sign-in; `nil` shows the
  /// paw.
  func photo(at path: String?) -> Data? {
    path.flatMap { photos[$0] }
  }

  /// Fetches the photo at a Pet's `photoPath` if it has one not fetched yet. A fetch that fails
  /// leaves the paw without an error, and the next call tries again.
  func loadPhoto(at path: String?) async {
    guard let path, photos[path] == nil,
      let data = try? await photoStore.fetch(path)
    else { return }
    photos[path] = data
  }

  /// Uploads `photo`, points the Pet with `id` at it, then deletes the file at `replaced`, and
  /// returns the Pet as stored. Returns `nil` when the Pet couldn't point to the new photo,
  /// deleting the new file if it was uploaded, so the Pet keeps its previous photo.
  private func savePhoto(_ photo: Data, of id: UUID, replacing replaced: String?) async -> Pet? {
    guard let path = try? await photoStore.upload(photo, for: id) else { return nil }
    let stored: Pet
    do {
      stored = try await store.setPhotoPath(path, of: id)
    } catch {
      try? await photoStore.remove(path)
      return nil
    }
    photos[path] = photo
    if let replaced, replaced != path {
      photos[replaced] = nil
      // A file left behind is unseen and loses nothing, so a failure isn't reported.
      try? await photoStore.remove(replaced)
    }
    return stored
  }
}

/// The loaded Pets' order: by name, then id, as the store sorts them.
private func nameOrder(_ lhs: Pet, _ rhs: Pet) -> Bool {
  switch lhs.name.localizedCompare(rhs.name) {
  case .orderedAscending: true
  case .orderedDescending: false
  case .orderedSame: lhs.id.uuidString < rhs.id.uuidString
  }
}

/// The Pet the Pets tab shows: the one with `id`, or the first when none is chosen or the
/// chosen one is gone, so a Household with Pets always shows one.
func selectedPet(_ id: UUID?, in pets: [Pet]) -> Pet? {
  pets.first { $0.id == id } ?? pets.first
}
