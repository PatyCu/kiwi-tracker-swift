import KiwiDesign
import KiwiDomain
import SwiftUI

/// The Today tab, as the reference app's `TodayScreen`: loading or the error with Retry until the
/// Household's Pets load, then the no-pets card when there are none. Today's content for a
/// Household with Pets is still a placeholder.
struct TodayScreen: View {
  let household: Household
  /// The Pets loaded since sign-in, shared with the Pets tab, so Retry here updates both.
  let model: PetsModel

  var body: some View {
    Group {
      switch model.state {
      case .loading:
        ScrollView { LoadingView().padding(.horizontal) }
      case .failed:
        ScrollView { LoadErrorView(onRetry: retry).padding(.horizontal) }
      case .ready(let loaded) where loaded.isEmpty:
        ScrollView {
          NoPetsCard(
            description: "Add a pet to see how they're doing today and log what happens."
          )
          .padding()
        }
      case .ready:
        // Today's content replaces this in Phase 4.
        ScrollView {
          PlaceholderCard(
            title: AppTab.today.title,
            description: "This screen arrives in a later migration phase.",
            systemImage: AppTab.today.systemImage
          )
          .padding()
        }
      }
    }
    .background(Palette.bg)
    .navigationTitle(todayTitle(for: household))
  }

  private func retry() {
    Task { await model.load() }
  }
}

#if DEBUG
  private func previewScreen(_ outcome: PreviewPetStore.Outcome) -> some View {
    NavigationStack { TodayScreen(household: .preview, model: .preview(outcome)) }
  }

  #Preview("Loaded") {
    previewScreen(.loads(Pet.previews))
  }

  #Preview("No pets") {
    previewScreen(.loads([]))
  }

  #Preview("Loading") {
    previewScreen(.staysLoading)
  }

  #Preview("Error") {
    previewScreen(.fails)
  }

  #Preview("Loaded, dark") {
    previewScreen(.loads(Pet.previews)).preferredColorScheme(.dark)
  }

  #Preview("No pets, dark") {
    previewScreen(.loads([])).preferredColorScheme(.dark)
  }

  #Preview("Loading, dark") {
    previewScreen(.staysLoading).preferredColorScheme(.dark)
  }

  #Preview("Error, dark") {
    previewScreen(.fails).preferredColorScheme(.dark)
  }
#endif
