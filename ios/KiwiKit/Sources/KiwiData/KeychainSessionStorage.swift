import Foundation
import Security
import Supabase

/// Keeps the Session in the Keychain on this device only, so it never moves to another device
/// through a backup. Reading or removing a missing Session isn't an error, as `AuthLocalStorage`
/// documents (supabase-swift's own Keychain storage throws for both).
struct KeychainSessionStorage: AuthLocalStorage {
  /// supabase-swift's service name, so the item its storage wrote is the one read and replaced.
  let service: String

  init(service: String = "supabase.gotrue.swift") {
    self.service = service
  }

  func store(key: String, value: Data) throws {
    // Removed first, so an item written under weaker protection is replaced, not updated.
    try remove(key: key)
    var query = itemQuery(key: key)
    query[kSecValueData as String] = value
    query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    try check(SecItemAdd(query as CFDictionary, nil))
  }

  func retrieve(key: String) throws -> Data? {
    var query = itemQuery(key: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound { return nil }
    try check(status)
    return result as? Data
  }

  func remove(key: String) throws {
    let status = SecItemDelete(itemQuery(key: key) as CFDictionary)
    if status == errSecItemNotFound { return }
    try check(status)
  }

  private func itemQuery(key: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
    ]
  }

  private func check(_ status: OSStatus) throws {
    guard status == errSecSuccess else { throw KeychainSessionStorageError(status: status) }
  }
}

struct KeychainSessionStorageError: Error, Equatable {
  let status: OSStatus
}
