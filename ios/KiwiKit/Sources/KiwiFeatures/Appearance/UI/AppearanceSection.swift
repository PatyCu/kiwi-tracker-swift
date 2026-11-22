import KiwiDesign
import SwiftUI

/// System, Light or Dark in Settings, as the reference app's `AppearanceSection`: one row per
/// choice with a radio button, the selected one filled, plus an icon per choice (ADR 0009).
struct AppearanceSection: View {
  @Environment(\.appearance) private var appearance

  var body: some View {
    Section("Appearance") {
      ForEach(Appearance.allCases, id: \.self) { option in
        AppearanceRow(option: option, isSelected: appearance.wrappedValue == option) {
          appearance.wrappedValue = option
        }
      }
    }
  }
}

/// One choice: its icon and name, then the radio button.
private struct AppearanceRow: View {
  let option: Appearance
  let isSelected: Bool
  let select: () -> Void
  @ScaledMetric(relativeTo: .body) private var radioSize = 20

  var body: some View {
    Button(action: select) {
      HStack {
        Label(option.label, systemImage: option.systemImage)
          .foregroundStyle(Palette.text)
        Spacer()
        Circle()
          .strokeBorder(
            isSelected ? Palette.kiwi : Palette.muted,
            lineWidth: isSelected ? radioSize * 0.3 : 2
          )
          .frame(width: radioSize, height: radioSize)
          .accessibilityHidden(true)
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#if DEBUG
  /// A Form with the section, tinted as `AppShell` and applying the choice as `AppRoot` does.
  private struct PreviewForm: View {
    @State var appearance: Appearance

    var body: some View {
      Form { AppearanceSection() }
        .scrollContentBackground(.hidden)
        .background(Palette.bg)
        .tint(Palette.kiwi)
        .environment(\.appearance, $appearance)
        .preferredColorScheme(appearance.colorScheme)
    }
  }

  #Preview("System") {
    PreviewForm(appearance: .system)
  }

  #Preview("System, dark device") {
    PreviewForm(appearance: .system).environment(\.colorScheme, .dark)
  }

  #Preview("Light") {
    PreviewForm(appearance: .light)
  }

  #Preview("Dark") {
    PreviewForm(appearance: .dark)
  }
#endif
