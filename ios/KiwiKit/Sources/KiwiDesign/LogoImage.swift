import SwiftUI

/// The Kiwi Tracker logo.
public struct LogoImage: View {
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
  LogoImage()
}
