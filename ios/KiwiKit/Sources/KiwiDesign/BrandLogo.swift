import SwiftUI

/// The Kiwi Tracker logo, as the reference app's `BrandLogo`.
public struct BrandLogo: View {
  private let size: CGFloat

  public init(size: CGFloat = 44) {
    self.size = size
  }

  public var body: some View {
    Image(.logo)
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
      .accessibilityLabel("Kiwi Tracker logo")
  }
}

#Preview {
  BrandLogo()
}
