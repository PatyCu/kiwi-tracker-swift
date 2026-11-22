import KiwiDesign
import SwiftUI

/// System, Light or Dark in Settings, as the reference app's `AppearanceSection`, with a native
/// checkmark picker in place of its radio card.
struct AppearanceSection: View {
  @Environment(\.appearance) private var appearance

  var body: some View {
    Section("Appearance") {
      Picker("Appearance", selection: appearance) {
        ForEach(Appearance.allCases, id: \.self) { option in
          Text(option.label).tag(option)
        }
      }
      .pickerStyle(.inline)
      .labelsHidden()
    }
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
