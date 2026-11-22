import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

/// The reference's `petStore` load cases.
@Suite struct SupabasePetStoreTests {
  @Test func loadsTheHouseholdsPetsByName() async throws {
    let sent = Mutex<URLComponents?>(nil)
    let backend = try RecordedSupabaseServer.backend { request, _ in
      sent.withLock {
        $0 = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      }
      return (
        200,
        #"""
        [{"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat"},
         {"id": "ffffffff-ffff-4fff-8fff-ffffffffffff", "name": "Luna", "species": "Dog"}]
        """#
      )
    }

    let pets = try await SupabasePetStore(backend: backend).loadPets()

    #expect(
      pets == [
        Pet(
          id: try #require(UUID(uuidString: "cccccccc-cccc-4ccc-8ccc-cccccccccccc")),
          name: "Kiwi",
          species: .cat
        ),
        Pet(
          id: try #require(UUID(uuidString: "ffffffff-ffff-4fff-8fff-ffffffffffff")),
          name: "Luna",
          species: .dog
        ),
      ]
    )
    let request = try #require(sent.withLock { $0 })
    #expect(request.path == "/rest/v1/pets")
    #expect(
      Set(request.queryItems ?? [])
        == [
          URLQueryItem(name: "select", value: "id,name,species"),
          URLQueryItem(name: "order", value: "name.asc.nullslast,id.asc.nullslast"),
        ]
    )
  }

  @Test func reportsAnUnknownSpeciesInsteadOfGuessing() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      (
        200,
        #"""
        [{"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat"},
         {"id": "ffffffff-ffff-4fff-8fff-ffffffffffff", "name": "Luna", "species": "Ferret"}]
        """#
      )
    }

    await #expect(throws: PetStoreError.invalidData) {
      try await SupabasePetStore(backend: backend).loadPets()
    }
  }

  @Test func wrapsAFailedLoadInATypedError() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      (500, #"{"code": "XX000", "message": "Recorded error"}"#)
    }

    await #expect(throws: PetStoreError.couldNotLoad) {
      try await SupabasePetStore(backend: backend).loadPets()
    }
  }

  @Test func throwsWhenSupabaseCannotBeReached() async throws {
    let backend = try RecordedSupabaseServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: PetStoreError.couldNotLoad) {
      try await SupabasePetStore(backend: backend).loadPets()
    }
  }
}
