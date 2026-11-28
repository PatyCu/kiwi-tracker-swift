import KiwiData
import KiwiFeatures
import SwiftUI

@main
struct KiwiTrackerApp: App {
  private let root: RootView

  init() {
    do {
      let backend = SupabaseBackend(config: try SupabaseConfig(bundle: .main))
      root = RootView(
        auth: SupabasePasswordAuth(backend: backend),
        households: SupabaseHouseholdStore(backend: backend),
        pets: SupabasePetStore(backend: backend),
        photos: CachedPetPhotoStore(store: SupabasePetPhotoStore(backend: backend))
      )
    } catch {
      // The message names the missing or invalid key, so whoever set up the build can fix it.
      root = RootView(signInUnavailable: error.description)
    }
  }

  var body: some Scene {
    WindowGroup {
      root
    }
  }
}
