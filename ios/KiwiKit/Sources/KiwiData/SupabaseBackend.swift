import Foundation
import Supabase

/// The app's single Supabase client. The app builds it once at launch and hands it to the
/// stores; nothing outside `KiwiData` sees the client itself.
public final class SupabaseBackend: Sendable {
  let client: SupabaseClient

  public convenience init(config: SupabaseConfig) {
    // The session is kept in the Keychain (supabase-swift's default on iOS).
    self.init(config: config, sessionStorage: KeychainLocalStorage(), urlSession: .shared)
  }

  /// Tests pass in-memory session storage and a `URLSession` that answers with recorded
  /// responses.
  init(config: SupabaseConfig, sessionStorage: any AuthLocalStorage, urlSession: URLSession) {
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
          autoRefreshToken: true,
          emitLocalSessionAsInitialSession: true
        ),
        global: SupabaseClientOptions.GlobalOptions(session: urlSession)
      )
    )
  }
}
