import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

@Suite struct SupabaseHouseholdStoreTests {
  @Test func returnsTheSignedInAccountsHousehold() async throws {
    let sent = Mutex<URLComponents?>(nil)
    let backend = try StubSupabaseServer.backend { request, _ in
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

  // Covers: HH-012
  @Test func trimsSpacesFromBothEndsOfTheAlias() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (200, #"[{"id": "22222222-2222-4222-8222-222222222222", "alias": "  The Burrow \n"}]"#)
    }

    let household = try await SupabaseHouseholdStore(backend: backend).loadHousehold()

    #expect(household?.alias == "The Burrow")
  }

  // Covers: HH-003
  @Test func returnsNilWhenTheAccountIsNotInAHousehold() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in (200, "[]") }

    #expect(try await SupabaseHouseholdStore(backend: backend).loadHousehold() == nil)
  }

  // Covers: HH-002
  @Test func throwsWhenTheQueryFails() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (500, #"{"code": "XX000", "message": "Stub error"}"#)
    }

    await #expect(throws: HouseholdStoreError.couldNotLoad) {
      try await SupabaseHouseholdStore(backend: backend).loadHousehold()
    }
  }

  // Covers: HH-002
  @Test func throwsWhenSupabaseCannotBeReached() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: HouseholdStoreError.couldNotLoad) {
      try await SupabaseHouseholdStore(backend: backend).loadHousehold()
    }
  }

  // Covers: HH-013
  @Test func returnsTheHouseholdsMembersSortedByDisplayName() async throws {
    let sent = Mutex<URLComponents?>(nil)
    let backend = try StubSupabaseServer.backend { request, _ in
      sent.withLock {
        $0 = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      }
      return (
        200,
        #"""
        [{"user_id": "11111111-1111-4111-8111-111111111111", "display_name": "Alex"},
         {"user_id": "33333333-3333-4333-8333-333333333333", "display_name": "Sam"}]
        """#
      )
    }

    let members = try await SupabaseHouseholdStore(backend: backend).loadMembers()

    #expect(
      members == [
        Member(
          accountID: try #require(UUID(uuidString: "11111111-1111-4111-8111-111111111111")),
          displayName: "Alex"
        ),
        Member(
          accountID: try #require(UUID(uuidString: "33333333-3333-4333-8333-333333333333")),
          displayName: "Sam"
        ),
      ]
    )
    let request = try #require(sent.withLock { $0 })
    #expect(request.path == "/rest/v1/household_members")
    #expect(
      Set(request.queryItems ?? [])
        == [
          URLQueryItem(name: "select", value: "user_id,display_name"),
          URLQueryItem(name: "order", value: "display_name.asc.nullslast"),
        ]
    )
  }

  // Covers: HH-015
  @Test func trimsSpacesFromBothEndsOfADisplayName() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (200, #"[{"user_id": "11111111-1111-4111-8111-111111111111", "display_name": " Alex \n"}]"#)
    }

    let members = try await SupabaseHouseholdStore(backend: backend).loadMembers()

    #expect(members.map(\.displayName) == ["Alex"])
  }

  // Covers: HH-017
  @Test func throwsWhenTheMembersQueryFails() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (500, #"{"code": "XX000", "message": "Stub error"}"#)
    }

    await #expect(throws: HouseholdStoreError.couldNotLoad) {
      try await SupabaseHouseholdStore(backend: backend).loadMembers()
    }
  }
}
