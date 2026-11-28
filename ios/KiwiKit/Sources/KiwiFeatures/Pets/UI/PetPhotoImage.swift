import KiwiDesign
import KiwiDomain
import SwiftUI

/// A Pet's photo at `size`, filling the square with rounded corners, or the paw when it has none
/// or it hasn't been fetched. Fetches the photo through `pets` when it appears, so a photo
/// already on the device shows without a download, and one that can't be fetched leaves the paw.
struct PetPhotoImage: View {
  let pet: Pet
  let pets: PetsModel
  let size: CGFloat
  let cornerRadius: CGFloat

  var body: some View {
    Group {
      if let data = pets.photo(at: pet.photoPath), let photo = UIImage(data: data) {
        Image(uiImage: photo)
          .resizable()
          .scaledToFill()
          .accessibilityLabel("\(pet.name) photo")
      } else {
        Image(systemName: "pawprint.fill")
          .font(.title3)
          .foregroundStyle(Palette.kiwi)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          // A kiwi tint, so the paw stands out on either card surface.
          .background(Palette.kiwi.opacity(0.15))
          .accessibilityLabel("\(pet.name) avatar")
      }
    }
    .frame(width: size, height: size)
    .clipShape(.rect(cornerRadius: cornerRadius))
    .task(id: pet.photoPath) { await pets.loadPhoto(at: pet.photoPath) }
  }
}
