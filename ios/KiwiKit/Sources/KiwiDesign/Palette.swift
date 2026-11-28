import SwiftUI

/// The app's palette. Each token has a light and a dark value in the asset
/// catalog and follows the color scheme. Views use these instead of color
/// literals.
public enum Palette {
  public static let bg = Color(.bg)
  public static let surface = Color(.surface)
  public static let surface2 = Color(.surface2)
  public static let line = Color(.line)
  public static let text = Color(.text)
  public static let muted = Color(.muted)
  public static let kiwi = Color(.kiwi)
  public static let amber = Color(.amber)
  public static let statusAmber = Color(.statusAmber)
  public static let coral = Color(.coral)
  public static let blue = Color(.blue)
  public static let ink = Color(.ink)
  public static let note = Color(.note)
}

#Preview {
  let tokens: [(String, Color)] = [
    ("bg", Palette.bg), ("surface", Palette.surface), ("surface2", Palette.surface2),
    ("line", Palette.line), ("text", Palette.text), ("muted", Palette.muted),
    ("kiwi", Palette.kiwi), ("amber", Palette.amber), ("statusAmber", Palette.statusAmber),
    ("coral", Palette.coral), ("blue", Palette.blue), ("ink", Palette.ink), ("note", Palette.note),
  ]
  List(tokens, id: \.0) { name, color in
    Label {
      Text(name)
    } icon: {
      RoundedRectangle(cornerRadius: 6).fill(color).stroke(Palette.line)
    }
  }
}
