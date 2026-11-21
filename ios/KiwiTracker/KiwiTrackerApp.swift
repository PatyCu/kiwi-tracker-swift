import KiwiData
import KiwiFeatures
import SwiftUI

@main
struct KiwiTrackerApp: App {
  private let root: AppRoot

  init() {
    do {
      let backend = SupabaseBackend(config: try SupabaseConfig(bundle: .main))
      root = AppRoot(auth: SupabasePasswordAuth(backend: backend))
    } catch {
      // The message names the missing or invalid key, as the reference's setup error does.
      root = AppRoot(signInUnavailable: error.description)
    }
  }

  var body: some Scene {
    WindowGroup {
      root
    }
  }
}
