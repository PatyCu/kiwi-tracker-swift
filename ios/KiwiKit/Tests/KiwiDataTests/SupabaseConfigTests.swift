import Foundation
import Testing

@testable import KiwiData

private let localURL = "http://127.0.0.1:54321"
private let publishableKey = "sb_publishable_test"

@Suite struct SupabaseConfigTests {
  @Test func returnsTheTrimmedURLAndPublishableKey() throws {
    let config = try SupabaseConfig(url: " \(localURL) ", publishableKey: " \(publishableKey)\n")

    #expect(config.url == URL(string: localURL))
    #expect(config.publishableKey == publishableKey)
  }

  @Test(arguments: [nil, "", "   "])
  func rejectsAMissingURL(_ url: String?) {
    #expect(throws: SupabaseConfigError("SUPABASE_URL is not set.")) {
      try SupabaseConfig(url: url, publishableKey: publishableKey)
    }
  }

  @Test(arguments: ["127.0.0.1:54321", "ftp://example.com", "not a url"])
  func rejectsAURLThatIsNotHTTP(_ url: String) {
    #expect(throws: SupabaseConfigError("SUPABASE_URL must be an http(s) URL.")) {
      try SupabaseConfig(url: url, publishableKey: publishableKey)
    }
  }

  @Test(arguments: [nil, "", "  "])
  func rejectsAMissingPublishableKey(_ key: String?) {
    #expect(throws: SupabaseConfigError("SUPABASE_PUBLISHABLE_KEY is not set.")) {
      try SupabaseConfig(url: localURL, publishableKey: key)
    }
  }

  @Test func rejectsASecretKey() {
    let error = #expect(throws: SupabaseConfigError.self) {
      try SupabaseConfig(url: localURL, publishableKey: "sb_secret_abc")
    }
    #expect(error?.description.contains("holds a secret key") == true)
  }

  @Test func pointsDevelopersToTheSetupSteps() {
    let error = #expect(throws: SupabaseConfigError.self) {
      try SupabaseConfig(url: nil, publishableKey: nil)
    }
    #expect(error?.description.contains("README.md#run") == true)
  }
}
