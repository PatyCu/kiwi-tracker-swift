import KiwiDesign
import SwiftUI

/// System, Light or Dark in Settings, as the reference app's `AppearanceSection`: one row per
/// choice with a radio button, the selected one filled, plus an icon per choice.
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
  /// A Form with the section, tinted as `MainTabView` and applying the choice as `RootView` does.
  private func previewForm(_ appearance: Binding<Appearance>) -> some View {
    Form { AppearanceSection() }
      .scrollContentBackground(.hidden)
      .background(Palette.bg)
      .tint(Palette.kiwi)
      .environment(\.appearance, appearance)
      .preferredColorScheme(appearance.wrappedValue.colorScheme)
  }

  #Preview("System") {
    @Previewable @State var appearance = Appearance.system
    previewForm($appearance)
  }

  #Preview("System, dark device") {
    @Previewable @State var appearance = Appearance.system
    previewForm($appearance).environment(\.colorScheme, .dark)
  }

  #Preview("Light") {
    @Previewable @State var appearance = Appearance.light
    previewForm($appearance)
  }

  #Preview("Dark") {
    @Previewable @State var appearance = Appearance.dark
    previewForm($appearance)
  }
#endif
