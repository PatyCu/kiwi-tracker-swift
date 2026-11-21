import KiwiDesign
import KiwiDomain
import SwiftUI

/// The signed-in app: four tabs, each with its own navigation stack, opened
/// from `kiwitracker://` URLs, for the loaded `household`, which it also puts in the
/// environment. Each tab shows a placeholder until its feature is ported. Expects the
/// `SessionModel` in the environment.
public struct AppShell: View {
  private let household: Household
  @State private var navigation: AppNavigation

  public init(household: Household) {
    self.init(household: household, navigation: AppNavigation())
  }

  init(household: Household, navigation: AppNavigation) {
    self.household = household
    _navigation = State(initialValue: navigation)
  }

  public var body: some View {
    @Bindable var navigation = navigation
    TabView(selection: $navigation.selectedTab) {
      tab(.today) {
        NavigationStack {
          PlaceholderScreen(tab: .today, navigationTitle: todayTitle(for: household))
        }
      }
      tab(.pets) {
        NavigationStack(path: $navigation.petsPath) {
          PlaceholderScreen(tab: .pets, navigationTitle: petsTitle(for: household))
            .routeDestinations()
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
    .environment(\.household, household)
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
  let navigationTitle: String

  init(title: String, systemImage: String) {
    self.title = title
    self.systemImage = systemImage
    navigationTitle = title
  }

  /// The tab's placeholder, titled with the tab's label unless `navigationTitle` is given.
  init(tab: AppTab, navigationTitle: String? = nil) {
    title = tab.title
    systemImage = tab.systemImage
    self.navigationTitle = navigationTitle ?? tab.title
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
    .navigationTitle(navigationTitle)
  }
}

private let previewPetID = UUID()

#Preview("Today") {
  AppShell(household: .preview).previewSession()
}

#Preview("Pet profile") {
  AppShell(
    household: .preview,
    navigation: AppNavigation(
      selectedTab: .pets,
      petsPath: [.pet(previewPetID), .petProfile(previewPetID)]
    )
  )
  .previewSession()
}

#Preview("Dark") {
  AppShell(household: .preview, navigation: AppNavigation(selectedTab: .calendar))
    .previewSession()
    .preferredColorScheme(.dark)
}
