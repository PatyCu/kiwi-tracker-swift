import KiwiDesign
import KiwiDomain
import SwiftUI

/// One Pet in the Pets tab's selector: its photo or the paw, and the name, with a checkmark and a kiwi
/// border when selected, and an Edit button under the name. Selecting and editing are two sibling
/// buttons, so editing never changes the selection.
struct PetSelectorCard: View {
  let pet: Pet
  let pets: PetsModel
  let isSelected: Bool
  let onSelect: () -> Void
  let onEdit: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      PetPhotoImage(pet: pet, pets: pets, size: 58, cornerRadius: 13)
        .allowsHitTesting(false)
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 4) {
          Text(pet.name)
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(Palette.text)
            .lineLimit(1)
          if isSelected {
            Image(systemName: "checkmark.circle.fill")
              .font(.subheadline)
              .foregroundStyle(Palette.kiwi)
          }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        Button(action: onEdit) {
          Text("Edit")
            .font(.caption2)
            .underline()
            .foregroundStyle(Palette.muted)
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit \(pet.name)")
      }
      .padding(.top, 9)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(9)
    .frame(width: 172, alignment: .leading)
    .frame(minHeight: 78, alignment: .top)
    // The whole card selects; the photo and name let taps through to it.
    .background {
      Button(action: onSelect) {
        Color.clear.contentShape(.rect(cornerRadius: 17))
      }
      .buttonStyle(.plain)
      .accessibilityLabel(pet.name)
      // VoiceOver announces the selection itself, as iOS does for a selected item.
      .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    .background(isSelected ? Palette.surface : Palette.surface2, in: .rect(cornerRadius: 17))
    .overlay(
      RoundedRectangle(cornerRadius: 17)
        .strokeBorder(isSelected ? Palette.kiwi : Palette.line, lineWidth: isSelected ? 2 : 1)
        .allowsHitTesting(false)
    )
  }
}

#if DEBUG
  /// Kiwi with a photo, Luna with the paw, each selected and not.
  private func previewRow() -> some View {
    let pets = PetsModel.preview()
    return ScrollView(.horizontal) {
      HStack(spacing: 10) {
        PetSelectorCard(
          pet: Pet.previews[0], pets: pets, isSelected: true, onSelect: {}, onEdit: {})
        PetSelectorCard(
          pet: Pet.previews[1], pets: pets, isSelected: false, onSelect: {}, onEdit: {})
        PetSelectorCard(
          pet: Pet.previews[0], pets: pets, isSelected: false, onSelect: {}, onEdit: {})
        PetSelectorCard(
          pet: Pet.previews[1], pets: pets, isSelected: true, onSelect: {}, onEdit: {})
        AddPetCard {}
      }
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Palette.bg)
  }

  #Preview("Light") {
    previewRow().preferredColorScheme(.light)
  }

  #Preview("Dark") {
    previewRow().preferredColorScheme(.dark)
  }
#endif
