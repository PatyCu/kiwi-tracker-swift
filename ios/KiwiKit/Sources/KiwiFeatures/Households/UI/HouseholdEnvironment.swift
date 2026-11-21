import KiwiDomain
import SwiftUI

extension EnvironmentValues {
  /// The signed-in Account's Household. The tabs only open once it has loaded, so it is set
  /// everywhere inside them.
  @Entry var household: Household?
}
