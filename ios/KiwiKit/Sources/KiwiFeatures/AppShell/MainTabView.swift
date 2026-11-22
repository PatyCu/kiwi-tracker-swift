import KiwiDesign
import KiwiDomain
import SwiftUI

/// The signed-in app: four tabs, each with its own navigation stack, for the
/// loaded `household`, which it also puts in the environment, its `members`,
/// which Settings loads, and its `pets`, loaded since sign-in. Each tab shows a
/// placeholder until its feature is ported. Expects the `SessionModel` in the
/// environment.
struct MainTabView: View {
  private let household: Household
  private let members: MembersModel
  private let pets: PetsModel
  @State private var navigation: AppNavigation

  init(
    household: Household,
    members: MembersModel,
    pets: PetsModel,
    navigation: AppNavigation = AppNavigation()
  ) {
    self.household = household
    self.members = members
    self.pets = pets
    _navigation = State(initialValue: navigation)
  }

  var body: some View {
    @Bindable var navigation = navigation
    TabView(selection: $navigation.selectedTab) {
      tab(.today) {
        NavigationStack {
          PlaceholderScreen(tab: .today, navigationTitle: todayTitle(for: household))
        }
      }
      tab(.pets) {
        NavigationStack(path: $navigation.petsPath) {
          PetsScreen(household: household, model: pets).routeDestinations()
        }
      }
      tab(.calendar) {
        NavigationStack(path: $navigation.calendarPath) {
          PlaceholderScreen(tab: .calendar).routeDestinations()
        }
      }
      tab(.settings) {
        NavigationStack { SettingsScreen(members: members) }
      }
    }
    .tint(Palette.kiwi)
    .environment(\.household, household)
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
      case .petOverview: PlaceholderScreen(title: "Pet overview", systemImage: "pawprint")
      case .petDetails: PlaceholderScreen(title: "Details", systemImage: "person.text.rectangle")
      case .petEvent:
        PlaceholderScreen(title: "Pet event details", systemImage: "list.bullet.rectangle")
      }
    }
  }
}

/// Stands in for a screen that hasn't been ported yet.
struct PlaceholderScreen: View {
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
  MainTabView(household: .preview, members: .preview(), pets: .preview()).previewSession()
}

#Preview("Pet details") {
  MainTabView(
    household: .preview,
    members: .preview(), pets: .preview(),
    navigation: AppNavigation(
      selectedTab: .pets,
      petsPath: [.petOverview(previewPetID), .petDetails(previewPetID)]
    )
  )
  .previewSession()
}

#Preview("Dark") {
  MainTabView(
    household: .preview,
    members: .preview(), pets: .preview(),
    navigation: AppNavigation(selectedTab: .calendar)
  )
  .previewSession()
  .preferredColorScheme(.dark)
}
