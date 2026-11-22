import KiwiDesign
import KiwiDomain
import SwiftUI

/// Who is in the signed-in Account's Household, by Display name, as the Members row of the
/// reference app's `HouseholdSection`. iOS gives them their own section, a row each.
struct MembersSection: View {
  let model: HouseholdMembersModel
  private let loadError: LocalizedStringResource = "Could not load the members."

  var body: some View {
    Section("Members") {
      switch model.state {
      case .loading:
        Text("Loading…").foregroundStyle(Palette.muted)
      case .failed:
        HStack {
          Text(loadError).foregroundStyle(Palette.coral)
          Spacer()
          Button("Retry") { Task { await model.load() } }
            .buttonStyle(.borderless)
            .foregroundStyle(Palette.kiwi)
            .bold()
        }
      case .ready(let members):
        ForEach(members, id: \.accountID) { member in
          if model.isSignedIn(member) {
            Text("\(member.displayName)\(Text(" (you)").foregroundStyle(Palette.muted))")
              .accessibilityLabel("\(member.displayName), you")
          } else {
            Text(member.displayName)
          }
        }
      }
    }
    // Started outside the view's task so switching tabs mid-load doesn't cancel it.
    .onAppear { Task { await model.loadOnce() } }
    .onChange(of: model.state) { _, state in
      // The reference marks the error as an alert, which screen readers announce.
      if state == .failed {
        AccessibilityNotification.Announcement(String(localized: loadError)).post()
      }
    }
  }
}

#if DEBUG
  private func previewForm(_ outcome: PreviewHouseholdStore.Outcome) -> some View {
    Form {
      MembersSection(model: .preview(outcome))
    }
    .scrollContentBackground(.hidden)
    .background(Palette.bg)
  }

  #Preview("Loaded") {
    previewForm(.loads(.preview))
  }

  #Preview("Loading") {
    previewForm(.staysLoading)
  }

  #Preview("Error") {
    previewForm(.fails)
  }

  #Preview("Loaded, dark") {
    previewForm(.loads(.preview)).preferredColorScheme(.dark)
  }

  #Preview("Loading, dark") {
    previewForm(.staysLoading).preferredColorScheme(.dark)
  }

  #Preview("Error, dark") {
    previewForm(.fails).preferredColorScheme(.dark)
  }
#endif
