import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

@Suite struct SupabasePetStoreTests {
  // Covers: PET-002
  @Test func loadsTheHouseholdsPetsByName() async throws {
    let sent = Mutex<URLComponents?>(nil)
    let backend = try StubSupabaseServer.backend { request, _ in
      sent.withLock {
        $0 = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      }
      return (
        200,
        #"""
        [{"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat",
          "breed": "European shorthair", "birth_date": "2021-04-12",
          "photo_path": "cccccccc-cccc-4ccc-8ccc-cccccccccccc/1762621200000.jpg"},
         {"id": "ffffffff-ffff-4fff-8fff-ffffffffffff", "name": "Luna", "species": "Dog",
          "breed": null, "birth_date": null, "photo_path": null}]
        """#
      )
    }

    let pets = try await SupabasePetStore(backend: backend).loadPets()

    #expect(
      pets == [
        Pet(
          id: try #require(UUID(uuidString: "cccccccc-cccc-4ccc-8ccc-cccccccccccc")),
          name: "Kiwi",
          species: .cat,
          breed: "European shorthair",
          birthDate: BirthDate(year: 2021, month: 4, day: 12),
          photoPath: "cccccccc-cccc-4ccc-8ccc-cccccccccccc/1762621200000.jpg"
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
          URLQueryItem(name: "select", value: "id,name,species,breed,birth_date,photo_path"),
          URLQueryItem(name: "order", value: "name.asc.nullslast,id.asc.nullslast"),
        ]
    )
  }

  // Covers: PET-011
  @Test func reportsAnUnknownSpeciesInsteadOfGuessing() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
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

  // Covers: PET-007
  @Test func wrapsAFailedLoadInATypedError() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (500, #"{"code": "XX000", "message": "Stub error"}"#)
    }

    await #expect(throws: PetStoreError.couldNotLoad) {
      try await SupabasePetStore(backend: backend).loadPets()
    }
  }

  // Covers: PET-007
  @Test func throwsWhenSupabaseCannotBeReached() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      throw URLError(.notConnectedToInternet)
    }

    await #expect(throws: PetStoreError.couldNotLoad) {
      try await SupabasePetStore(backend: backend).loadPets()
    }
  }

  // Covers: PET-031
  @Test func addsAPetToTheGivenHouseholdAsOneRow() async throws {
    let householdID = try #require(UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"))
    let sent = Mutex<(URLRequest, Data)?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
      sent.withLock { $0 = (request, body) }
      return (201, kiwiRow)
    }

    let pet = try await SupabasePetStore(backend: backend).addPet(
      PetDetails(
        name: "Kiwi", species: .cat, breed: "European shorthair",
        birthDate: BirthDate(year: 2021, month: 4, day: 12)),
      to: householdID
    )

    #expect(pet == (try storedKiwi()))
    let (request, body) = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "POST")
    #expect(request.url?.path == "/rest/v1/pets")
    #expect(try queryValue("select", of: request) == "id,name,species,breed,birth_date,photo_path")
    #expect(
      try json(body)
        == [
          "household_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa", "name": "Kiwi", "species": "Cat",
          "breed": "European shorthair", "birth_date": "2021-04-12",
        ]
    )
  }

  // Covers: PET-021, PET-022
  @Test func savesOnePetByIDAndClearsFieldsLeftEmpty() async throws {
    let sent = Mutex<(URLRequest, Data)?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
      sent.withLock { $0 = (request, body) }
      return (
        200,
        #"""
        {"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat",
         "breed": null, "birth_date": null}
        """#
      )
    }

    let kiwi = try storedKiwi()
    let pet = try await SupabasePetStore(backend: backend).updatePet(
      kiwi.id, PetDetails(name: "Kiwi", species: .cat))

    #expect(pet == Pet(id: kiwi.id, name: "Kiwi", species: .cat))
    let (request, body) = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "PATCH")
    #expect(try queryValue("id", of: request) == "eq.cccccccc-cccc-4ccc-8ccc-cccccccccccc")
    #expect(try queryValue("select", of: request) == "id,name,species,breed,birth_date,photo_path")
    #expect(
      try json(body)
        == ["name": "Kiwi", "species": "Cat", "breed": NSNull(), "birth_date": NSNull()]
    )
  }

  // Covers: PHOTO-012
  @Test func recordsWhereAPetPhotoIsStoredAndTouchesNothingElse() async throws {
    let sent = Mutex<(URLRequest, Data)?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
      sent.withLock { $0 = (request, body) }
      return (
        200,
        #"""
        {"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat",
         "breed": "European shorthair", "birth_date": "2021-04-12",
         "photo_path": "cccccccc-cccc-4ccc-8ccc-cccccccccccc/new.jpg"}
        """#
      )
    }
    let kiwi = try storedKiwi()

    let pet = try await SupabasePetStore(backend: backend).setPhotoPath(
      "cccccccc-cccc-4ccc-8ccc-cccccccccccc/new.jpg", of: kiwi.id)

    #expect(pet.photoPath == "cccccccc-cccc-4ccc-8ccc-cccccccccccc/new.jpg")
    #expect(pet.details == kiwi.details)
    let (request, body) = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "PATCH")
    #expect(try queryValue("id", of: request) == "eq.cccccccc-cccc-4ccc-8ccc-cccccccccccc")
    #expect(try json(body) == ["photo_path": "cccccccc-cccc-4ccc-8ccc-cccccccccccc/new.jpg"])
  }

  // Covers: PET-029
  @Test func wrapsAFailedWriteInATypedError() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (403, #"{"code": "42501", "message": "Stub error"}"#)
    }
    let store = SupabasePetStore(backend: backend)
    let kiwi = try storedKiwi()

    await #expect(throws: PetStoreError.couldNotSave) {
      try await store.addPet(PetDetails(name: "Kiwi", species: .cat), to: UUID())
    }
    await #expect(throws: PetStoreError.couldNotSave) {
      try await store.updatePet(kiwi.id, PetDetails(name: "Kiwi", species: .cat))
    }
    await #expect(throws: PetStoreError.couldNotSave) {
      try await store.setPhotoPath("\(kiwi.id)/new.jpg", of: kiwi.id)
    }
  }
}

nonisolated private let kiwiRow = #"""
  {"id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc", "name": "Kiwi", "species": "Cat",
   "breed": "European shorthair", "birth_date": "2021-04-12"}
  """#

/// The Pet `kiwiRow` stores.
private func storedKiwi() throws -> Pet {
  Pet(
    id: try #require(UUID(uuidString: "cccccccc-cccc-4ccc-8ccc-cccccccccccc")),
    name: "Kiwi",
    species: .cat,
    breed: "European shorthair",
    birthDate: BirthDate(year: 2021, month: 4, day: 12)
  )
}

/// The value of the query item `name`, lowercased: the SDK sends ids in uppercase.
private func queryValue(_ name: String, of request: URLRequest) throws -> String? {
  let url = try #require(request.url)
  return URLComponents(url: url, resolvingAgainstBaseURL: false)?
    .queryItems?.first { $0.name == name }?.value?.lowercased()
}

/// The JSON object sent, with `household_id` lowercased: the SDK sends ids in uppercase.
private func json(_ body: Data) throws -> NSDictionary {
  let sent = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
  return sent.mapValues { value in
    (value as? String).map { UUID(uuidString: $0)?.uuidString.lowercased() ?? $0 } ?? value
  } as NSDictionary
}
