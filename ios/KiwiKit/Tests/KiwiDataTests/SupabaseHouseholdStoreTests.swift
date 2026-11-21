import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

@Suite struct SupabaseHouseholdStoreTests {
  @Test func returnsTheSignedInAccountsHousehold() async throws {
    let sent = Mutex<URLComponents?>(nil)
    let backend = try RecordedSupabaseServer.backend { request, _ in
      sent.withLock {
        $0 = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      }
      return (200, #"[{"id": "22222222-2222-4222-8222-222222222222", "alias": "The Burrow"}]"#)
    }

    let household = try await SupabaseHouseholdStore(backend: backend).loadHousehold()

    #expect(
      household
        == Household(
          id: try #require(UUID(uuidString: "22222222-2222-4222-8222-222222222222")),
          alias: "The Burrow"
        )
    )
    let request = try #require(sent.withLock { $0 })
    #expect(request.path == "/rest/v1/households")
    #expect(request.queryItems == [URLQueryItem(name: "select", value: "id,alias")])
  }

  @Test func trimsSpacesFromBothEndsOfTheAlias() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      (200, #"[{"id": "22222222-2222-4222-8222-222222222222", "alias": "  The Burrow \n"}]"#)
    }

    let household = try await SupabaseHouseholdStore(backend: backend).loadHousehold()

    #expect(household?.alias == "The Burrow")
  }

  @Test func returnsNilWhenTheAccountIsNotInAHousehold() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in (200, "[]") }

    #expect(try await SupabaseHouseholdStore(backend: backend).loadHousehold() == nil)
  }

  @Test func throwsWhenTheQueryFails() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      (500, #"{"code": "XX000", "message": "Recorded error"}"#)
    }

    await #expect(throws: HouseholdStoreError.couldNotLoad) {
      try await SupabaseHouseholdStore(backend: backend).loadHousehold()
    }
  }

  @Test func throwsWhenSupabaseCannotBeReached() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: HouseholdStoreError.couldNotLoad) {
      try await SupabaseHouseholdStore(backend: backend).loadHousehold()
    }
  }
}
