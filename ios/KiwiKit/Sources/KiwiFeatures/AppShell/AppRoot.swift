import KiwiDesign
import KiwiDomain
import SwiftUI

/// The app's root: sign-in until someone is signed in, then their Household, then the tabs.
/// Shows why sign-in is unavailable when the app can't set it up. The order follows the
/// reference app's `RootStack`. Holds the appearance above all of it, so the choice covers every
/// screen and lasts through sign-out until the app quits.
public struct AppRoot: View {
  private enum Setup {
    case ready(any PasswordAuth, any HouseholdStore, any PetStore)
    case unavailable(String)
  }

  private let setup: Setup
  @State private var appearance = Appearance.system

  public init(auth: any PasswordAuth, households: any HouseholdStore, pets: any PetStore) {
    setup = .ready(auth, households, pets)
  }

  /// For a build that can't offer sign-in; `message` says why.
  public init(signInUnavailable message: String) {
    setup = .unavailable(message)
  }

  public var body: some View {
    Group {
      switch setup {
      case .ready(let auth, let households, let pets):
        SessionRoot(auth: auth, households: households, pets: pets)
      case .unavailable(let message): SignInUnavailableScreen(message: message)
      }
    }
    .environment(\.appearance, $appearance)
    .preferredColorScheme(appearance.colorScheme)
  }
}

/// Switches on who is signed in.
private struct SessionRoot: View {
  let auth: any PasswordAuth
  let households: any HouseholdStore
  let pets: any PetStore
  @State private var session: SessionModel

  init(auth: any PasswordAuth, households: any HouseholdStore, pets: any PetStore) {
    self.auth = auth
    self.households = households
    self.pets = pets
    _session = State(initialValue: SessionModel(auth: auth))
  }

  var body: some View {
    Group {
      switch session.state {
      case .loading:
        // Reading the stored session takes a moment; a blank screen avoids flashing sign-in.
        Palette.bg.ignoresSafeArea()
      case .signedOut:
        SignInScreen(auth: auth)
      case .signedIn(let user):
        // A new Household, Pets and shell for each sign-in: a new Account never sees the
        // previous Household or its Pets, and every tab starts fresh on Today.
        HouseholdRoot(households: households, pets: pets, user: user).id(user.id)
      }
    }
    .environment(session)
    .task { await session.observe() }
  }
}

/// Waits for the signed-in Account's Household: loading, then the tabs, an error with Retry, or
/// the no-household screen. Saving pets and the screen titles need the Household. The Pets load
/// alongside it, as the reference's `PetsProvider` loads per user, and the Pets tab waits for
/// them.
private struct HouseholdRoot: View {
  let email: String
  @State private var household: HouseholdModel
  /// Loaded by Settings, not here, so a failure never keeps the tabs closed.
  @State private var members: HouseholdMembersModel
  @State private var pets: PetsModel

  init(households: any HouseholdStore, pets: any PetStore, user: SignedInUser) {
    email = user.email
    _household = State(initialValue: HouseholdModel(store: households))
    _members = State(
      initialValue: HouseholdMembersModel(store: households, signedInAccountID: user.id))
    _pets = State(initialValue: PetsModel(store: pets))
  }

  var body: some View {
    Group {
      switch household.state {
      case .loading:
        LoadingView().centeredOnBackground()
      case .failed:
        // Features that load alongside the Household add their reload to this Retry, so one
        // Retry is enough to open the app.
        LoadErrorView(onRetry: reload).centeredOnBackground()
      case .missing:
        NoHouseholdScreen(email: email, onCheckAgain: reload) { SignOutButton() }
      case .ready(let loaded):
        AppShell(household: loaded, members: members, pets: pets)
      }
    }
    .task { await household.load() }
    .task { await pets.load() }
  }

  /// Retry and "Check again" reload the Pets too: they likely failed with the Household, and an
  /// Account just added to a Household has its Pets now.
  private func reload() {
    Task { await household.load() }
    Task { await pets.load() }
  }
}

extension View {
  fileprivate func centeredOnBackground() -> some View {
    padding(24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Palette.bg)
  }
}

#if DEBUG
  private func signedIn(_ outcome: PreviewHouseholdStore.Outcome) -> AppRoot {
    AppRoot(
      auth: PreviewPasswordAuth(user: .preview),
      households: PreviewHouseholdStore(outcome: outcome),
      pets: PreviewPetStore()
    )
  }

  #Preview("Signed out") {
    AppRoot(
      auth: PreviewPasswordAuth(), households: PreviewHouseholdStore(), pets: PreviewPetStore())
  }

  #Preview("Signed in") {
    signedIn(.loads(.preview))
  }

  #Preview("Loading the household") {
    signedIn(.staysLoading)
  }

  #Preview("Household error") {
    signedIn(.fails)
  }

  #Preview("No household") {
    signedIn(.missing)
  }

  #Preview("Sign-in unavailable") {
    AppRoot(signInUnavailable: PreviewPasswordAuth.setupError)
  }
#endif
