import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// A JPEG `width` by `height` pixels, as a photo from the library would be, optionally with
/// location metadata.
nonisolated func testPhoto(width: Int, height: Int, location: Bool = false) -> Data {
  let context = CGContext(
    data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
  context?.setFillColor(CGColor(gray: 0.5, alpha: 1))
  context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
  let output = NSMutableData()
  guard let image = context?.makeImage(),
    let destination = CGImageDestinationCreateWithData(
      output, UTType.jpeg.identifier as CFString, 1, nil)
  else { return Data() }
  var properties: [CFString: Any] = [:]
  if location {
    properties[kCGImagePropertyGPSDictionary] = [
      kCGImagePropertyGPSLatitude: 40.4168, kCGImagePropertyGPSLatitudeRef: "N",
      kCGImagePropertyGPSLongitude: 3.7038, kCGImagePropertyGPSLongitudeRef: "W",
    ]
  }
  CGImageDestinationAddImage(destination, image, properties as CFDictionary)
  CGImageDestinationFinalize(destination)
  return output as Data
}

/// The pixel size and properties of the image in `data`.
nonisolated func imageProperties(of data: Data) -> [CFString: Any] {
  guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return [:] }
  return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] ?? [:]
}
