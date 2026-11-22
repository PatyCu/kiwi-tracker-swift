import KiwiDesign
import SwiftUI

/// Shown in place of a tab's content while the Household has no Pets, as the reference app's
/// `NoPetsCard`. `description` says what adding a Pet unlocks on that tab. The reference's
/// "Add your first pet" button arrives with the add-pet sheet in KIW-23.
struct NoPetsCard: View {
  let description: String

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "pawprint")
        .font(.title2)
        .foregroundStyle(Palette.muted)
        .frame(width: 52, height: 52)
        .background(Palette.surface2, in: .rect(cornerRadius: 16))
        .padding(.bottom, 4)
        .accessibilityHidden(true)
      Text("No pets yet")
        .font(.headline.weight(.heavy))
        .foregroundStyle(Palette.text)
        .accessibilityAddTraits(.isHeader)
      Text(description)
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 22)
    .padding(.vertical, 28)
    .background(Palette.surface, in: .rect(cornerRadius: 22))
    .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.line))
  }
}

#if DEBUG
  private func previewCard() -> some View {
    NoPetsCard(description: "Add a pet to keep their profile, photo and health history together.")
      .padding()
      .frame(maxHeight: .infinity)
      .background(Palette.bg)
  }

  #Preview("Light") {
    previewCard().preferredColorScheme(.light)
  }

  #Preview("Dark") {
    previewCard().preferredColorScheme(.dark)
  }
#endif
