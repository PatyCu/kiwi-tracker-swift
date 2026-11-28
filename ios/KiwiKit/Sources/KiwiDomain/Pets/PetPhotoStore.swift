import Foundation

/// Why a Pet's photo couldn't be stored, removed or fetched.
public enum PetPhotoStoreError: Error, Equatable, Sendable {
  case couldNotUpload
  case couldNotRemove
  case couldNotFetch
}

/// The Household's Pet photos, as JPEG files in its photo storage. Access rules only let a
/// Member reach the photos of their Household's Pets.
public protocol PetPhotoStore: Sendable {
  /// Stores `jpeg` as a new photo of the Pet with `petID`, and returns its path. Never
  /// overwrites: each photo gets a path of its own.
  func upload(_ jpeg: Data, for petID: UUID) async throws(PetPhotoStoreError) -> String
  /// Deletes the photo file at `path`.
  func remove(_ path: String) async throws(PetPhotoStoreError)
  /// The photo stored at `path`.
  func fetch(_ path: String) async throws(PetPhotoStoreError) -> Data
}

/// A photo store that keeps each photo on this device by its path, so it's downloaded once.
/// A new photo has a new path, so a kept photo never goes stale.
public protocol PetPhotoCache: PetPhotoStore {
  /// Removes every photo kept on this device, so the next Account on it can't see them.
  func clear() async
}
