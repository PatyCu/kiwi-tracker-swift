import Foundation
import KiwiDomain
import Synchronization

/// The Household's photo storage for tests. Uploads are recorded and stored at
/// `<pet id>/<n>.jpg`, numbered from 1; fetches answer with the stored data and are recorded.
/// Each operation fails while its flag is set. `whileRemoving` runs inside every removal, before
/// it answers.
nonisolated final class RecordingPetPhotoStore: PetPhotoCache {
  private let stored: Mutex<[String: Data]>
  private let recordedUploads = Mutex<[UUID]>([])
  private let recordedRemovals = Mutex<[String]>([])
  private let recordedFetches = Mutex<[String]>([])
  private let clearCount = Mutex(0)
  private let failures = Mutex<Set<PetPhotoStoreError>>([])
  private let whileRemoving: @Sendable (String) -> Void

  var uploads: [UUID] { recordedUploads.withLock { $0 } }
  var removals: [String] { recordedRemovals.withLock { $0 } }
  var fetches: [String] { recordedFetches.withLock { $0 } }
  var clears: Int { clearCount.withLock { $0 } }
  var files: [String: Data] { stored.withLock { $0 } }

  init(
    _ files: [String: Data] = [:], whileRemoving: @escaping @Sendable (String) -> Void = { _ in }
  ) {
    stored = Mutex(files)
    self.whileRemoving = whileRemoving
  }

  /// Makes `error`'s operation fail, or succeed again.
  func fail(_ error: PetPhotoStoreError, _ fails: Bool = true) {
    failures.withLock { failures in
      if fails { failures.insert(error) } else { failures.remove(error) }
    }
  }

  func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String {
    let count = recordedUploads.withLock {
      $0.append(petID); return $0.count
    }
    if failing(.couldNotUpload) { throw .couldNotUpload }
    let path = "\(petID)/\(count).jpg"
    stored.withLock { $0[path] = jpeg }
    return path
  }

  func remove(_ path: String) async throws(PetPhotoStoreError) {
    recordedRemovals.withLock { $0.append(path) }
    whileRemoving(path)
    if failing(.couldNotRemove) { throw .couldNotRemove }
    _ = stored.withLock { $0.removeValue(forKey: path) }
  }

  func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data {
    recordedFetches.withLock { $0.append(path) }
    guard !failing(.couldNotFetch), let data = stored.withLock({ $0[path] }) else {
      throw .couldNotFetch
    }
    return data
  }

  func clear() async {
    clearCount.withLock { $0 += 1 }
  }

  private func failing(_ error: PetPhotoStoreError) -> Bool {
    failures.withLock { $0.contains(error) }
  }
}
