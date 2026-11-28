import Foundation
import ImageIO
import Testing

@testable import KiwiFeatures

@Suite struct PreparedPetPhotoTests {
  // Covers: PHOTO-008
  @Test func scalesAPhotoDownTo512pxAndStoresItAsJPEG() throws {
    let prepared = try preparedPetPhoto(from: testPhoto(width: 3000, height: 4000))

    let properties = imageProperties(of: prepared)
    #expect(properties[kCGImagePropertyPixelWidth] as? Int == 512)
    #expect(properties[kCGImagePropertyPixelHeight] as? Int == 512)
    let source = try #require(CGImageSourceCreateWithData(prepared as CFData, nil))
    #expect(CGImageSourceGetType(source) as String? == "public.jpeg")
  }

  // Covers: PHOTO-009
  @Test func keepsASmallPhotoAtItsSize() throws {
    let prepared = try preparedPetPhoto(from: testPhoto(width: 300, height: 200))

    let properties = imageProperties(of: prepared)
    #expect(properties[kCGImagePropertyPixelWidth] as? Int == 200)
    #expect(properties[kCGImagePropertyPixelHeight] as? Int == 200)
  }

  // Covers: PHOTO-005
  @Test func reportsAPhotoItCannotRead() {
    #expect(throws: PetPhotoPreparationError.unreadable) {
      try preparedPetPhoto(from: Data("not a photo".utf8))
    }
  }

  // Covers: PHOTO-010
  @Test func storesAPhotoWithoutItsLocation() throws {
    let original = testPhoto(width: 800, height: 600, location: true)
    #expect(imageProperties(of: original)[kCGImagePropertyGPSDictionary] != nil)

    let prepared = try preparedPetPhoto(from: original)

    #expect(imageProperties(of: prepared)[kCGImagePropertyGPSDictionary] == nil)
  }
}
