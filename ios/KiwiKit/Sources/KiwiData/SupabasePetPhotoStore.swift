import Foundation
import KiwiDomain
import Supabase

/// The Household's Pet photos in the private `pet-photos` bucket, reached through the signed-in
/// Session. Files live at `<pet id>/<milliseconds since 1970>.jpg`.
public struct SupabasePetPhotoStore: PetPhotoStore {
  private static let bucket = "pet-photos"
  private let backend: SupabaseBackend
  private let now: @Sendable () -> Date

  public init(backend: SupabaseBackend) {
    self.init(backend: backend, now: { .now })
  }

  /// Tests pass the clock that names a new file.
  init(backend: SupabaseBackend, now: @escaping @Sendable () -> Date) {
    self.backend = backend
    self.now = now
  }

  public func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String {
    // Lowercased as Postgres writes a uuid, so the folder matches the access rules' pet id.
    let milliseconds = Int64((now().timeIntervalSince1970 * 1000).rounded(.down))
    let path = "\(petID.uuidString.lowercased())/\(milliseconds).jpg"
    do {
      try await files.upload(path, data: jpeg, options: FileOptions(contentType: "image/jpeg"))
    } catch {
      throw .couldNotUpload
    }
    return path
  }

  public func remove(_ path: String) async throws(PetPhotoStoreError) {
    do {
      try await files.remove(paths: [path])
    } catch {
      throw .couldNotRemove
    }
  }

  public func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data {
    do {
      return try await files.download(path: path)
    } catch {
      throw .couldNotFetch
    }
  }

  private var files: StorageFileApi { backend.client.storage.from(Self.bucket) }
}
