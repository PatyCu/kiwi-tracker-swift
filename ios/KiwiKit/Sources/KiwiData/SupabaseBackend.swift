import Foundation
import Supabase

/// The app's single Supabase client. The app builds it once at launch and hands it to the
/// stores; nothing outside `KiwiData` sees the client itself.
public final class SupabaseBackend: Sendable {
  let client: SupabaseClient

  public convenience init(config: SupabaseConfig) {
    self.init(
      config: config,
      sessionStorage: KeychainSessionStorage(),
      installDefaults: .standard,
      urlSession: .shared
    )
  }

  /// Tests pass in-memory session storage, defaults of their own and a `URLSession` that
  /// answers with recorded responses.
  init(
    config: SupabaseConfig,
    sessionStorage: any AuthLocalStorage,
    installDefaults: UserDefaults,
    urlSession: URLSession
  ) {
    // supabase-swift's default key, passed explicitly so the key cleared below is the one the
    // client reads. `SupabaseConfig` guarantees the host.
    let host = config.url.host(percentEncoded: false) ?? ""
    let sessionKey = "sb-\(host.split(separator: ".").first ?? "")-auth-token"
    Self.clearSessionLeftByAPreviousInstall(
      key: sessionKey, storage: sessionStorage, installDefaults: installDefaults)

    // Tokens refresh automatically only while the app is active: the SDK starts and stops
    // refreshing on UIApplication's become-active and resign-active notifications.
    // The stored session is emitted as the initial session, as supabase-js does (and without it
    // the SDK reports a runtime issue at launch); callers must check `session.isExpired`.
    client = SupabaseClient(
      supabaseURL: config.url,
      supabaseKey: config.publishableKey,
      options: SupabaseClientOptions(
        auth: SupabaseClientOptions.AuthOptions(
          storage: sessionStorage,
          storageKey: sessionKey,
          autoRefreshToken: true,
          emitLocalSessionAsInitialSession: true
        ),
        global: SupabaseClientOptions.GlobalOptions(session: urlSession)
      )
    )
  }

  private static let hasLaunchedKey = "kiwi.hasLaunched"

  /// iOS keeps the Keychain when the app is deleted but deletes its UserDefaults, so a missing
  /// flag means a new install, whose first launch shows sign-in as the reference's does. The flag
  /// is set only once the session is gone, so a failed removal is retried on the next launch.
  private static func clearSessionLeftByAPreviousInstall(
    key: String, storage: any AuthLocalStorage, installDefaults: UserDefaults
  ) {
    guard !installDefaults.bool(forKey: hasLaunchedKey) else { return }
    do {
      try storage.remove(key: key)
      installDefaults.set(true, forKey: hasLaunchedKey)
    } catch {
      // Left unset: the next launch tries again.
    }
  }
}
