import SwiftUI

/// The logo next to the app's name, as the reference app's `AppIdentity`.
public struct AppNameLabel: View {
  public init() {}

  public var body: some View {
    HStack(spacing: 10) {
      LogoImage(size: 48)
      Text("Kiwi Tracker")
        .font(.title2.weight(.heavy))
        .foregroundStyle(Palette.text)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Kiwi Tracker")
  }
}

#Preview {
  AppNameLabel()
}
