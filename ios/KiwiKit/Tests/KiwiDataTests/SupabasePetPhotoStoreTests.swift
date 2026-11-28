import Foundation
import KiwiDomain
import Synchronization
import Testing

@testable import KiwiData

private let kiwiID = UUID(uuidString: "cccccccc-cccc-4ccc-8ccc-cccccccccccc") ?? UUID()

@Suite struct SupabasePetPhotoStoreTests {
  @Test func storesEachNewPhotoUnderItsOwnNameInThePetsFolder() async throws {
    let sent = Mutex<(URLRequest, Data)?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
      sent.withLock { $0 = (request, body) }
      return (
        200, #"{"Key": "pet-photos/stored.jpg", "Id": "dddddddd-dddd-4ddd-8ddd-dddddddddddd"}"#
      )
    }
    let store = SupabasePetPhotoStore(backend: backend) {
      Date(timeIntervalSince1970: 1_762_621_200)
    }

    let path = try await store.upload(Data("jpeg bytes".utf8), for: kiwiID)

    // The folder is the Pet's id as the database writes it, lowercased, so access rules match it.
    #expect(path == "cccccccc-cccc-4ccc-8ccc-cccccccccccc/1762621200000.jpg")
    let (request, body) = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "POST")
    #expect(
      request.url?.path
        == "/storage/v1/object/pet-photos/cccccccc-cccc-4ccc-8ccc-cccccccccccc/1762621200000.jpg")
    #expect(request.value(forHTTPHeaderField: "x-upsert") == "false")
    let form = String(decoding: body, as: UTF8.self)
    #expect(form.contains("Content-Type: image/jpeg"))
    #expect(form.contains("jpeg bytes"))
  }

  @Test func wrapsARefusedUploadInATypedError() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (403, #"{"statusCode": "403", "error": "Unauthorized", "message": "Stub error"}"#)
    }

    await #expect(throws: PetPhotoStoreError.couldNotUpload) {
      try await SupabasePetPhotoStore(backend: backend).upload(Data("jpeg".utf8), for: kiwiID)
    }
  }

  @Test func deletesOnePhotoFileByPath() async throws {
    let sent = Mutex<(URLRequest, Data)?>(nil)
    let backend = try StubSupabaseServer.backend { request, body in
      sent.withLock { $0 = (request, body) }
      return (200, "[]")
    }

    try await SupabasePetPhotoStore(backend: backend).remove("kiwi-id/old.jpg")

    let (request, body) = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "DELETE")
    #expect(request.url?.path == "/storage/v1/object/pet-photos")
    let sentJSON = try JSONSerialization.jsonObject(with: body) as? NSDictionary
    #expect(sentJSON == ["prefixes": ["kiwi-id/old.jpg"]])
  }

  @Test func wrapsAFailedDeleteInATypedError() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (500, #"{"statusCode": "500", "error": "Internal", "message": "Stub error"}"#)
    }

    await #expect(throws: PetPhotoStoreError.couldNotRemove) {
      try await SupabasePetPhotoStore(backend: backend).remove("kiwi-id/old.jpg")
    }
  }

  @Test func downloadsAPhotoByPathThroughTheSession() async throws {
    let sent = Mutex<URLRequest?>(nil)
    let backend = try StubSupabaseServer.backend { request, _ in
      sent.withLock { $0 = request }
      return (200, "jpeg bytes")
    }

    let data = try await SupabasePetPhotoStore(backend: backend).fetch("kiwi-id/1.jpg")

    #expect(data == Data("jpeg bytes".utf8))
    let request = try #require(sent.withLock { $0 })
    #expect(request.httpMethod == "GET")
    #expect(request.url?.path == "/storage/v1/object/pet-photos/kiwi-id/1.jpg")
  }

  @Test func wrapsAFailedDownloadInATypedError() async throws {
    let backend = try StubSupabaseServer.backend { _, _ in
      (400, #"{"statusCode": "404", "error": "not_found", "message": "Object not found"}"#)
    }

    await #expect(throws: PetPhotoStoreError.couldNotFetch) {
      try await SupabasePetPhotoStore(backend: backend).fetch("kiwi-id/gone.jpg")
    }
  }
}
