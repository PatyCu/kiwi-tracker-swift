import KiwiDesign
import KiwiDomain
import SwiftUI

/// One Pet in the Pets tab's selector: a paw avatar and the name, with a checkmark and a kiwi
/// border when selected, as the reference app's `PetSelectorCard`.
struct PetSelectorCard: View {
  let pet: Pet
  let isSelected: Bool
  let onSelect: () -> Void

  var body: some View {
    Button(action: onSelect) {
      HStack(alignment: .top, spacing: 10) {
        Image(systemName: "pawprint.fill")
          .font(.title3)
          .foregroundStyle(Palette.kiwi)
          .frame(width: 58, height: 58)
          // A kiwi tint, so the avatar stands out on the selected card's surface too.
          .background(Palette.kiwi.opacity(0.15), in: .rect(cornerRadius: 13))
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
        .padding(.top, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(9)
      .frame(width: 172, alignment: .leading)
      .frame(minHeight: 78)
      .background(isSelected ? Palette.surface : Palette.surface2, in: .rect(cornerRadius: 17))
      .overlay(
        RoundedRectangle(cornerRadius: 17)
          .strokeBorder(isSelected ? Palette.kiwi : Palette.line, lineWidth: isSelected ? 2 : 1)
      )
      .contentShape(.rect(cornerRadius: 17))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(pet.name)
    // VoiceOver announces the selection itself, as iOS does for a selected item.
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#if DEBUG
  private func previewCards() -> some View {
    HStack(spacing: 10) {
      PetSelectorCard(pet: Pet.previews[0], isSelected: true) {}
      PetSelectorCard(pet: Pet.previews[1], isSelected: false) {}
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Palette.bg)
  }

  #Preview("Light") {
    previewCards().preferredColorScheme(.light)
  }

  #Preview("Dark") {
    previewCards().preferredColorScheme(.dark)
  }
#endif
