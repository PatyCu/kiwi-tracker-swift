import Foundation

/// The Supabase project the app talks to, read from the scheme's xcconfig through Info.plist.
public struct SupabaseConfig: Equatable, Sendable {
  public let url: URL
  public let publishableKey: String

  /// Reads `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from the bundle's Info.plist.
  /// Throws a `SupabaseConfigError` that names the missing or invalid key.
  public init(bundle: Bundle) throws(SupabaseConfigError) {
    try self.init(
      url: bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
      publishableKey: bundle.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String
    )
  }

  /// Validates the connection settings. Throws a `SupabaseConfigError` that names the missing
  /// or invalid key.
  public init(url: String?, publishableKey: String?) throws(SupabaseConfigError) {
    let url = url?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let publishableKey = publishableKey?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if url.isEmpty { throw SupabaseConfigError("SUPABASE_URL is not set.") }
    guard let httpURL = Self.httpURL(url) else {
      throw SupabaseConfigError("SUPABASE_URL must be an http(s) URL.")
    }

    if publishableKey.isEmpty { throw SupabaseConfigError("SUPABASE_PUBLISHABLE_KEY is not set.") }
    // The key is bundled into the app, so a secret key there would leak it.
    if publishableKey.hasPrefix("sb_secret_") {
      throw SupabaseConfigError(
        "SUPABASE_PUBLISHABLE_KEY holds a secret key; use the publishable key."
      )
    }

    self.url = httpURL
    self.publishableKey = publishableKey
  }

  private static func httpURL(_ value: String) -> URL? {
    guard let components = URLComponents(string: value),
      let scheme = components.scheme?.lowercased(),
      scheme == "http" || scheme == "https",
      let host = components.host, !host.isEmpty
    else { return nil }
    return components.url
  }
}

public struct SupabaseConfigError: Error, Equatable, CustomStringConvertible {
  private static let setupHint =
    "Set it in the scheme's xcconfig in ios/Config and rebuild. See README.md#run."

  public let description: String

  init(_ message: String) {
    description = "\(message) \(Self.setupHint)"
  }
}
