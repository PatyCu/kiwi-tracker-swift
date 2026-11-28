import SwiftUI

/// A section's action, shown as a small outlined pill.
public struct SectionAction {
  /// Short visible label, such as "Schedule".
  public let label: String
  /// What VoiceOver announces; it should contain the visible label.
  public let accessibilityLabel: String
  /// An SF Symbol.
  public let systemImage: String
  public let action: () -> Void

  public init(
    label: String,
    accessibilityLabel: String,
    systemImage: String,
    action: @escaping () -> Void
  ) {
    self.label = label
    self.accessibilityLabel = accessibilityLabel
    self.systemImage = systemImage
    self.action = action
  }
}

/// A section's title with an optional action. `compact` drops the spacing above
/// and below.
public struct SectionHeader: View {
  private let title: String
  private let action: SectionAction?
  private let compact: Bool

  public init(_ title: String, action: SectionAction? = nil, compact: Bool = false) {
    self.title = title
    self.action = action
    self.compact = compact
  }

  public var body: some View {
    HStack(spacing: 12) {
      Text(title)
        .font(.title3.weight(.heavy))
        .foregroundStyle(Palette.text)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
      if let action {
        SectionActionButton(action)
      }
    }
    .padding(.top, compact ? 0 : 28)
    .padding(.bottom, compact ? 0 : 12)
  }
}

/// A section's action as a small outlined pill, for headers that aren't a
/// `SectionHeader`.
public struct SectionActionButton: View {
  private let action: SectionAction

  public init(_ action: SectionAction) {
    self.action = action
  }

  public var body: some View {
    Button(action: action.action) {
      HStack(spacing: 4) {
        Image(systemName: action.systemImage)
          .font(.subheadline)
        Text(action.label)
          .font(.footnote.bold())
      }
      .foregroundStyle(Palette.kiwi)
      .padding(.leading, 10)
      .padding(.trailing, 13)
      .frame(minHeight: 32)
      .background(Palette.kiwi.opacity(0.07), in: .capsule)
      .overlay(Capsule().strokeBorder(Palette.kiwi))
      // Keeps a 44pt touch target around the smaller pill.
      .contentShape(.interaction, Rectangle().inset(by: -6))
    }
    .buttonStyle(PressedOpacityButtonStyle())
    .accessibilityLabel(action.accessibilityLabel)
  }
}

private struct PressedOpacityButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.opacity(configuration.isPressed ? 0.7 : 1)
  }
}

private func previewHeaders() -> some View {
  VStack(alignment: .leading, spacing: 0) {
    SectionHeader("Overview", compact: true)
    SectionHeader(
      "Upcoming care",
      action: SectionAction(
        label: "Schedule",
        accessibilityLabel: "Schedule calendar event",
        systemImage: "plus",
        action: {}
      )
    )
    SectionHeader("More")
    SectionActionButton(
      SectionAction(
        label: "Edit",
        accessibilityLabel: "Edit Kiwi",
        systemImage: "square.and.pencil",
        action: {}
      )
    )
  }
  .padding()
  .frame(maxHeight: .infinity, alignment: .top)
  .background(Palette.bg)
}

#Preview("Light") {
  previewHeaders()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
  previewHeaders()
    .preferredColorScheme(.dark)
}
