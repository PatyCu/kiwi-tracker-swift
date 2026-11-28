import Foundation
import KiwiDomain

/// Keeps each Pet photo in the app's Caches folder by its storage path, and fetches from `store`
/// only the photos it hasn't kept. A new photo has a new path, so a kept file never goes stale. A
/// photo just uploaded is kept as sent, and a removed one is dropped. A file it can't write or
/// remove is left alone: the photo is fetched again next time, and clearing removes the folder.
public final class CachedPetPhotoStore: PetPhotoCache {
  private let store: any PetPhotoStore
  private let folder: URL

  public convenience init(store: any PetPhotoStore) {
    self.init(store: store, folder: URL.cachesDirectory.appending(path: "pet-photos"))
  }

  init(store: any PetPhotoStore, folder: URL) {
    self.store = store
    self.folder = folder
  }

  public func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String {
    let path = try await store.upload(jpeg, for: petID)
    keep(jpeg, at: path)
    return path
  }

  public func remove(_ path: String) async throws(PetPhotoStoreError) {
    // Dropped first: nobody points to the file any more, even if deleting it fails.
    try? FileManager.default.removeItem(at: file(for: path))
    try await store.remove(path)
  }

  public func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data {
    if let kept = try? Data(contentsOf: file(for: path)) { return kept }
    let data = try await store.fetch(path)
    keep(data, at: path)
    return data
  }

  public func clear() async {
    try? FileManager.default.removeItem(at: folder)
  }

  private func keep(_ data: Data, at path: String) {
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    try? data.write(to: file(for: path), options: .atomic)
  }

  /// One flat file per path, its name the path percent-encoded, so no path can reach outside
  /// the folder.
  private func file(for path: String) -> URL {
    let name = path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    return folder.appending(path: name)
  }
}
