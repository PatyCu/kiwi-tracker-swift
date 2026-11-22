import SwiftUI

/// How the app looks, as the reference app's `Appearance`: following the device, or always light
/// or dark. Held in memory by `RootView`, so every launch starts at System, as in the reference.
enum Appearance: CaseIterable, Hashable {
  case system, light, dark

  var label: LocalizedStringKey {
    switch self {
    case .system: "System"
    case .light: "Light"
    case .dark: "Dark"
    }
  }

  var systemImage: String {
    switch self {
    case .system: "circle.lefthalf.filled"
    case .light: "sun.max"
    case .dark: "moon"
    }
  }

  /// System is `nil`, so the app follows the device.
  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
}

extension EnvironmentValues {
  /// The app's appearance, set by `RootView` everywhere below it.
  @Entry var appearance: Binding<Appearance> = .constant(.system)
}
