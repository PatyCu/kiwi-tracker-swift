import KiwiData
import KiwiFeatures
import SwiftUI

@main
struct KiwiTrackerApp: App {
  private let backend: SupabaseBackend

  init() {
    do {
      backend = SupabaseBackend(config: try SupabaseConfig(bundle: .main))
    } catch {
      // A build without valid Supabase settings can't do anything; the message names the key.
      fatalError(error.description)
    }
  }

  var body: some Scene {
    WindowGroup {
      AppShell()
    }
  }
}
