import SwiftUI

/// A card with an icon, a title and a description, standing in for content
/// still to come. `systemImage` is an SF Symbol, a calendar by default.
public struct PlaceholderCard: View {
  private let title: String
  private let description: String
  private let systemImage: String

  public init(title: String, description: String, systemImage: String = "calendar") {
    self.title = title
    self.description = description
    self.systemImage = systemImage
  }

  public var body: some View {
    HStack(spacing: 13) {
      Image(systemName: systemImage)
        .font(.title3)
        .foregroundStyle(Palette.muted)
        .frame(width: 44, height: 44)
        .background(Palette.surface2, in: .rect(cornerRadius: 14))
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.subheadline.bold())
          .foregroundStyle(Palette.text)
        Text(description)
          .font(.caption)
          .foregroundStyle(Palette.muted)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(16)
    .background(Palette.surface, in: .rect(cornerRadius: 18))
    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.line))
    .accessibilityElement(children: .combine)
  }
}

private func previewCards() -> some View {
  VStack(spacing: 12) {
    PlaceholderCard(
      title: "No overdue items",
      description: "Overdue care will appear here when calendar events are implemented."
    )
    PlaceholderCard(
      title: "Nothing scheduled in the next 7 days",
      description: "Scheduled vet visits, vaccines and medicines will show here.",
      systemImage: "pawprint"
    )
  }
  .padding()
  .frame(maxHeight: .infinity)
  .background(Palette.bg)
}

#Preview("Light") {
  previewCards()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
  previewCards()
    .preferredColorScheme(.dark)
}
