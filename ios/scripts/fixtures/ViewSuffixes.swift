// swift-format-ignore-file
// The View-suffix check in check-conventions.sh must report exactly the lines marked "flagged".
// Not compiled; each declaration is a shape the check has to handle.
import SwiftUI

struct PetOverview: View {}  // flagged
@MainActor struct QuickLog: View {}  // flagged
private struct Baz<T: Collection<Int>>: View, Equatable {}  // flagged
struct Qux:  // flagged
  View
{}
public struct Timeline: SwiftUI.View where Self: Sendable {}  // flagged
extension Outer.Inner: View {}  // flagged

struct PetEventRow: View {}
@available(iOS 26, *) public struct LogoImage: View {}
struct Wrapper<Content: View>: Equatable {}
struct PressedButtonStyle: ButtonStyle, Viewable {}
