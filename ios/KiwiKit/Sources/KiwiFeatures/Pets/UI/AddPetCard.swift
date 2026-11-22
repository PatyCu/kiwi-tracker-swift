import KiwiDesign
import SwiftUI

/// The dashed card after the Pets in the selector that adds another Pet, as the reference app's
/// add card in `PetSelector`.
struct AddPetCard: View {
  let onAdd: () -> Void

  var body: some View {
    Button(action: onAdd) {
      HStack(spacing: 10) {
        Image(systemName: "plus")
          .font(.title3.weight(.semibold))
          .foregroundStyle(Palette.kiwi)
          .frame(width: 58, height: 58)
          .background(Palette.kiwi.opacity(0.1), in: .rect(cornerRadius: 13))
          .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(Palette.kiwi, style: dashed))
        VStack(alignment: .leading, spacing: 3) {
          Text("Add pet")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(Palette.kiwi)
          Text("Add details")
            .font(.caption2)
            .foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(9)
      .frame(width: 172, alignment: .leading)
      .frame(minHeight: 78)
      .background(Palette.surface2, in: .rect(cornerRadius: 17))
      .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(Palette.kiwi, style: dashed))
      .contentShape(.rect(cornerRadius: 17))
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Add another pet")
    .accessibilityAddTraits(.isButton)
  }

  private var dashed: StrokeStyle { StrokeStyle(lineWidth: 1, dash: [4, 3]) }
}
