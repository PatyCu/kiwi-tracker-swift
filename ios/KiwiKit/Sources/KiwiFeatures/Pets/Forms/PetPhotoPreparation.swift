import Foundation
import ImageIO
import UniformTypeIdentifiers

/// The picked data isn't an image ImageIO can read.
enum PetPhotoPreparationError: Error, Equatable {
  case unreadable
}

/// The longest side a stored Pet photo has: the largest view is 92pt, under 300px on a 3x screen.
nonisolated private let storedSide = 512

/// The photo in `data` as stored: the centre square, scaled down so its side is at most 512px and
/// never up, as a JPEG at quality 0.72 with none of the original's metadata, so no location or
/// camera details leave the device. JPEG rather than HEIC, so browsers can show it too. Reads a
/// thumbnail with the photo's orientation applied instead of decoding the full-size image.
nonisolated func preparedPetPhoto(from data: Data) throws(PetPhotoPreparationError) -> Data {
  guard let source = CGImageSourceCreateWithData(data as CFData, nil),
    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
    let width = properties[kCGImagePropertyPixelWidth] as? Int,
    let height = properties[kCGImagePropertyPixelHeight] as? Int,
    width > 0, height > 0
  else { throw .unreadable }

  // The thumbnail's size caps its longer side; this one keeps the shorter side at 512px, or at
  // its own size when smaller.
  let shorter = min(width, height)
  let longer = max(width, height)
  let longerSide =
    shorter > storedSide
    ? Int((Double(storedSide) * Double(longer) / Double(shorter)).rounded(.up)) : longer
  let options: [CFString: Any] = [
    kCGImageSourceCreateThumbnailFromImageAlways: true,
    kCGImageSourceCreateThumbnailWithTransform: true,
    kCGImageSourceShouldCacheImmediately: true,
    kCGImageSourceThumbnailMaxPixelSize: longerSide,
  ]
  guard let scaled = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
  else { throw .unreadable }

  let side = min(scaled.width, scaled.height, storedSide)
  let square = CGRect(
    x: (scaled.width - side) / 2, y: (scaled.height - side) / 2, width: side, height: side)
  let output = NSMutableData()
  guard let cropped = scaled.cropping(to: square),
    let destination = CGImageDestinationCreateWithData(
      output, UTType.jpeg.identifier as CFString, 1, nil)
  else { throw .unreadable }
  // Only the quality is written, so none of the source's properties are copied.
  CGImageDestinationAddImage(
    destination, cropped, [kCGImageDestinationLossyCompressionQuality: 0.72] as CFDictionary)
  guard CGImageDestinationFinalize(destination) else { throw .unreadable }
  return output as Data
}
