import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

@Suite struct CachedPetPhotoStoreTests {
  @Test func fetchesAPathOnceAndThenServesIt() async throws {
    let storage = CountingPhotoStore()
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())

    #expect(try await cache.fetch("kiwi/1.jpg") == Data("kiwi/1.jpg".utf8))
    #expect(try await cache.fetch("kiwi/1.jpg") == Data("kiwi/1.jpg".utf8))

    #expect(storage.fetches == ["kiwi/1.jpg"])
  }

  @Test func keepsPhotosForTheNextLaunch() async throws {
    let storage = CountingPhotoStore()
    let folder = temporaryFolder()
    _ = try await CachedPetPhotoStore(store: storage, folder: folder).fetch("kiwi/1.jpg")

    let relaunched = CachedPetPhotoStore(store: storage, folder: folder)

    #expect(try await relaunched.fetch("kiwi/1.jpg") == Data("kiwi/1.jpg".utf8))
    #expect(storage.fetches == ["kiwi/1.jpg"])
  }

  @Test func fetchesANewPath() async throws {
    let storage = CountingPhotoStore()
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())
    _ = try await cache.fetch("kiwi/1.jpg")

    #expect(try await cache.fetch("kiwi/2.jpg") == Data("kiwi/2.jpg".utf8))

    #expect(storage.fetches == ["kiwi/1.jpg", "kiwi/2.jpg"])
  }

  @Test func fetchesAgainAfterClearing() async throws {
    let storage = CountingPhotoStore()
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())
    _ = try await cache.fetch("kiwi/1.jpg")

    await cache.clear()
    _ = try await cache.fetch("kiwi/1.jpg")

    #expect(storage.fetches == ["kiwi/1.jpg", "kiwi/1.jpg"])
  }

  @Test func servesAnUploadedPhotoWithoutFetchingIt() async throws {
    let storage = CountingPhotoStore()
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())

    let path = try await cache.upload(Data("new".utf8), for: UUID())

    #expect(try await cache.fetch(path) == Data("new".utf8))
    #expect(storage.fetches.isEmpty)
  }

  @Test func fetchesAgainOnceTheFileIsRemoved() async throws {
    let storage = CountingPhotoStore()
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())
    _ = try await cache.fetch("kiwi/1.jpg")

    try await cache.remove("kiwi/1.jpg")
    _ = try? await cache.fetch("kiwi/1.jpg")

    #expect(storage.removals == ["kiwi/1.jpg"])
    #expect(storage.fetches == ["kiwi/1.jpg", "kiwi/1.jpg"])
  }

  @Test func passesOnAFailedFetch() async throws {
    let storage = CountingPhotoStore()
    storage.fetchFails = true
    let cache = CachedPetPhotoStore(store: storage, folder: temporaryFolder())

    await #expect(throws: PetPhotoStoreError.couldNotFetch) {
      try await cache.fetch("kiwi/1.jpg")
    }
    storage.fetchFails = false
    #expect(try await cache.fetch("kiwi/1.jpg") == Data("kiwi/1.jpg".utf8))
  }
}

private func temporaryFolder() -> URL {
  FileManager.default.temporaryDirectory.appending(path: "pet-photos-\(UUID().uuidString)")
}

/// Photo storage that answers each fetch with the path's bytes and records what reaches it.
private final class CountingPhotoStore: PetPhotoStore {
  private let recordedFetches = Mutex<[String]>([])
  private let recordedRemovals = Mutex<[String]>([])
  private let failing = Mutex(false)

  var fetches: [String] { recordedFetches.withLock { $0 } }
  var removals: [String] { recordedRemovals.withLock { $0 } }
  var fetchFails: Bool {
    get { failing.withLock { $0 } }
    set { failing.withLock { $0 = newValue } }
  }

  func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String {
    "\(petID)/\(UUID()).jpg"
  }

  func remove(_ path: String) async throws(PetPhotoStoreError) {
    recordedRemovals.withLock { $0.append(path) }
  }

  func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data {
    recordedFetches.withLock { $0.append(path) }
    if fetchFails { throw .couldNotFetch }
    return Data(path.utf8)
  }
}
