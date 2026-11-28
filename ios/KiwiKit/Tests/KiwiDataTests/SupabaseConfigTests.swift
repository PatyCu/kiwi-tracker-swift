import Foundation
import Testing

@testable import KiwiData

private let localURL = "http://127.0.0.1:54321"
private let publishableKey = "sb_publishable_test"

/// What `SupabaseConfig` throws for these settings, or `nil` when they're valid.
private func configError(url: String?, publishableKey: String?) -> SupabaseConfigError? {
  do {
    _ = try SupabaseConfig(url: url, publishableKey: publishableKey)
    return nil
  } catch {
    return error
  }
}

@Suite struct SupabaseConfigTests {
  @Test func returnsTheTrimmedURLAndPublishableKey() throws {
    let config = try SupabaseConfig(url: " \(localURL) ", publishableKey: " \(publishableKey)\n")

    #expect(config.url == URL(string: localURL))
    #expect(config.publishableKey == publishableKey)
  }

  @Test(arguments: [nil, "", "   "])
  func namesTheURLWhenItIsMissing(_ url: String?) throws {
    let error = try #require(configError(url: url, publishableKey: publishableKey))

    #expect(error.description.contains("SUPABASE_URL"))
  }

  @Test(arguments: ["127.0.0.1:54321", "ftp://example.com", "not a url"])
  func namesTheURLWhenItIsNotHTTP(_ url: String) throws {
    let error = try #require(configError(url: url, publishableKey: publishableKey))

    #expect(error.description.contains("SUPABASE_URL"))
    #expect(error != configError(url: nil, publishableKey: publishableKey))
  }

  @Test(arguments: [nil, "", "  "])
  func namesThePublishableKeyWhenItIsMissing(_ key: String?) throws {
    let error = try #require(configError(url: localURL, publishableKey: key))

    #expect(error.description.contains("SUPABASE_PUBLISHABLE_KEY"))
  }

  @Test func rejectsASecretKey() throws {
    let error = try #require(configError(url: localURL, publishableKey: "sb_secret_abc"))

    #expect(error.description.contains("SUPABASE_PUBLISHABLE_KEY"))
    #expect(error != configError(url: localURL, publishableKey: nil))
  }
}
