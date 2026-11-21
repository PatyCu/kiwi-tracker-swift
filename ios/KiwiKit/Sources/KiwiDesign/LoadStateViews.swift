import SwiftUI

/// What a screen shows in place of its data while it loads, as the reference
/// app's `Loading`.
public struct LoadingView: View {
  public init() {}

  public var body: some View {
    VStack(spacing: 10) {
      ProgressView()
        .controlSize(.large)
        .tint(Palette.kiwi)
      Text("Loading…")
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 80)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Loading")
  }
}

/// What a screen shows in place of its data when loading failed, with Retry,
/// as the reference app's `LoadError`.
public struct LoadErrorView: View {
  private let onRetry: () -> Void

  public init(onRetry: @escaping () -> Void) {
    self.onRetry = onRetry
  }

  public var body: some View {
    VStack(spacing: 10) {
      Text("Could not load your data")
        .font(.title2.bold())
        .foregroundStyle(Palette.text)
        .accessibilityAddTraits(.isHeader)
      Text("Check your connection and try again.")
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
      Text("Your saved data has not been changed.")
        .font(.subheadline)
        .foregroundStyle(Palette.muted)
      Button("Retry", action: onRetry)
        .font(.subheadline.weight(.heavy))
        .foregroundStyle(Palette.ink)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .controlSize(.large)
        .tint(Palette.kiwi)
        .padding(.top, 10)
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 80)
  }
}

#Preview("Loading, light") {
  LoadingView()
    .frame(maxHeight: .infinity)
    .background(Palette.bg)
    .preferredColorScheme(.light)
}

#Preview("Loading, dark") {
  LoadingView()
    .frame(maxHeight: .infinity)
    .background(Palette.bg)
    .preferredColorScheme(.dark)
}

#Preview("Error, light") {
  LoadErrorView {}
    .frame(maxHeight: .infinity)
    .background(Palette.bg)
    .preferredColorScheme(.light)
}

#Preview("Error, dark") {
  LoadErrorView {}
    .frame(maxHeight: .infinity)
    .background(Palette.bg)
    .preferredColorScheme(.dark)
}
