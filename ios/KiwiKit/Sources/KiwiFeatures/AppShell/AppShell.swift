import KiwiDesign
import SwiftUI

/// The signed-in app: four tabs, each with its own navigation stack, opened
/// from `kiwitracker://` URLs. Each tab shows a placeholder until its feature
/// is ported. Expects the `SessionModel` in the environment.
public struct AppShell: View {
  @State private var navigation: AppNavigation

  public init() {
    self.init(navigation: AppNavigation())
  }

  init(navigation: AppNavigation) {
    _navigation = State(initialValue: navigation)
  }

  public var body: some View {
    @Bindable var navigation = navigation
    TabView(selection: $navigation.selectedTab) {
      tab(.today) {
        NavigationStack { PlaceholderScreen(tab: .today) }
      }
      tab(.pets) {
        NavigationStack(path: $navigation.petsPath) {
          PlaceholderScreen(tab: .pets).routeDestinations()
        }
      }
      tab(.calendar) {
        NavigationStack(path: $navigation.calendarPath) {
          PlaceholderScreen(tab: .calendar).routeDestinations()
        }
      }
      tab(.settings) {
        NavigationStack { SettingsScreen() }
      }
    }
    .tint(Palette.kiwi)
    .onOpenURL { navigation.open($0) }
    .alert("Page not found", isPresented: $navigation.showsPageNotFound) {
      Button("Return to Today") { navigation.returnToToday() }
    }
  }

  private func tab(
    _ tab: AppTab,
    @ViewBuilder content: () -> some View
  ) -> some TabContent<AppTab> {
    Tab(tab.title, systemImage: tab.systemImage, value: tab, content: content)
  }
}

extension View {
  fileprivate func routeDestinations() -> some View {
    navigationDestination(for: Route.self) { route in
      switch route {
      case .pet: PlaceholderScreen(title: "Pet", systemImage: "pawprint")
      case .petProfile: PlaceholderScreen(title: "Profile", systemImage: "person.text.rectangle")
      case .record: PlaceholderScreen(title: "Event detail", systemImage: "list.bullet.rectangle")
      }
    }
  }
}

/// Stands in for a screen that hasn't been ported yet.
private struct PlaceholderScreen: View {
  let title: String
  let systemImage: String

  init(title: String, systemImage: String) {
    self.title = title
    self.systemImage = systemImage
  }

  init(tab: AppTab) {
    self.init(title: tab.title, systemImage: tab.systemImage)
  }

  var body: some View {
    ScrollView {
      PlaceholderCard(
        title: title,
        description: "This screen arrives in a later migration phase.",
        systemImage: systemImage
      )
      .padding()
    }
    .background(Palette.bg)
    .navigationTitle(title)
  }
}

private let previewPetID = UUID()

#Preview("Today") {
  AppShell().previewSession()
}

#Preview("Pet profile") {
  AppShell(
    navigation: AppNavigation(
      selectedTab: .pets,
      petsPath: [.pet(previewPetID), .petProfile(previewPetID)]
    )
  )
  .previewSession()
}

#Preview("Dark") {
  AppShell(navigation: AppNavigation(selectedTab: .calendar))
    .previewSession()
    .preferredColorScheme(.dark)
}
