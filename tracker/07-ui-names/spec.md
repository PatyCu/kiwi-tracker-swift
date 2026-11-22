# Consistent UI names from the glossary and iOS terms

Status: done

## Problem Statement

UI names drift between screens, the glossary and the reference app. The reference names one concept several ways: a logged Pet event is `pet_events`, a `records/[recordId]` route, `PetActivityCard` and `TimelineEvents`. A Pet's attributes are "Profile", which the glossary avoids for Pets. Its pieces carry React Native words (`Modal`, `Provider`) or no role at all (`PetOverview`, `QuickLog`). The iOS app has started copying these: `Route.record`, `Route.petProfile` and the "Event detail" placeholder. Its own views also break the pattern: `BrandLogo`, `AppIdentity`, `AppRoot`, `AppShell`, and `HouseholdMembersModel` next to `MembersSection`. Each port adds more names, and fixing them later costs more.

## Solution

Every UI name comes from a glossary term plus a fixed iOS suffix that says what kind of piece it is. Code and copy always name the kind of Event. A Pet's attributes are its details, and so are an Event's, so both are a details screen. `make lint` fails a `View` without an allowed suffix. The existing code is renamed now, and the reference's names are translated as each feature is ported.

## User Stories

1. As a developer, I want every UI type named `<glossary term><suffix>`, so that I can tell what a type is about and what kind of piece it is from its name.
2. As a developer, I want one fixed list of suffixes using iOS terms, so that the same kind of piece always has the same ending.
3. As a developer, I want React Native words (`Modal`, `Provider`) kept out of the iOS app, so that its code reads as SwiftUI.
4. As a developer, I want `make lint` to fail a `View` without an allowed suffix, so that drift is caught before review.
5. As a developer, I want the linter to need no named exceptions, so that the rule has no holes.
6. As a developer, I want Event, Pet event and Calendar event in the glossary, so that "event" means one thing everywhere.
7. As a developer, I want code to always name the kind of Event (`PetEventDetailsScreen`, `CalendarEventSheet`, `Route.petEvent`), so that no type is ambiguous.
8. As a Member, I want copy to say "Pet event" or "Calendar event" in full, so that I always know which kind I'm looking at.
9. As a Member, I want a Pet's attributes called its details ("Kiwi's details", "Edit details"), the same word as for an Event's attributes, so that the app is consistent.
10. As a developer, I want the routes named after their screens (`petOverview`, `petDetails`, `petEvent`), so that a route and its screen share a name.
11. As a developer, I want the members' model named `MembersModel`, so that it matches `MembersSection` and the glossary's Member.
12. As a developer, I want the logo and the logo-with-name views named after the SwiftUI type they act as (`LogoImage`, `AppNameLabel`), so that they follow the suffix list.
13. As a developer, I want the app's containers named as Apple's samples name them (`RootView`, `MainTabView`), so that their names say what they are.
14. As an agent porting a feature, I want the port-feature skill to tell me to name things from the glossary and the suffix list, not from the reference, so that I don't copy the reference's names.
15. As an agent porting a feature, I want copy that names a glossary term or a CONVENTIONS UI name to use ours, so that the screen and the code agree.
16. As a developer, I want the migration plan's and the tracker's feature lines to use the same names, so that the roadmap matches the code.
17. As a developer, I want the placeholder screens titled with the new names, so that previews already show the names that later screens will use.

## Implementation Decisions

- **Glossary**: **Event**, **Pet event** and **Calendar event** added. An Event is a Pet event (logged after it happened: Symptom, Diet change or Other) or a Calendar event (scheduled care). A Calendar event never becomes a Pet event. "Details" is a naming pattern, not a glossary term, and Pet keeps "profile" on its avoid list.
- **Suffixes** (`ios/CONVENTIONS.md`, UI): a UI type is `<glossary term><suffix>`, with one of these suffixes:

  | Suffix | Kind of piece |
  | --- | --- |
  | `Screen` | A tab's root or a pushed screen |
  | `Sheet` | A sheet (the reference's `Modal`) |
  | `Section` | A titled group in a screen |
  | `Header` | A section's title row |
  | `Card` | A boxed tile |
  | `Row` | One line of a list |
  | `Field` | One form input |
  | `Picker` | A choice made with a SwiftUI `Picker` |
  | `Button` | A button |
  | `Label` | An icon with text |
  | `Image` | An image |
  | `View` | Only the app's containers and the loading and load-error stand-ins |

  `Model` and `Form` stay the suffixes for state and form models, as now.
- **Details**: the screen for an entity's attributes is `<term>DetailsScreen`: a Pet's details (name, species, breed, date of birth, photo) and a Pet event's details.
- **Kinds of Event**: types, routes and copy always say Pet event or Calendar event, never "event" on its own.
- **Selector and picker**: `PetSelector` and `PetSelectorCard` set the Pets tab's selected Pet. `PetPicker` sets a Pet event's or a Calendar event's Pet, replacing the reference's `PetPicker` and `PetEventPetField`.
- **Copy rule**: the UI rule in `ios/CONVENTIONS.md` and step 3 of the port-feature skill widen the copy exception to "copy naming a domain concept or a UI piece uses its `GLOSSARY.md` term or its CONVENTIONS name", for example "Kiwi's details", "Edit details", "Pet event details" and "Add pet event".
- **Names aren't reference differences**: names and copy that follow the glossary and CONVENTIONS are implementation details, not intentional differences from the reference. They need neither the developer's confirmation nor a note in a feature's spec. Architecture principle 1 says so: clients match the reference's copy apart from the names the glossary and CONVENTIONS set, and principle 2's confirmation doesn't apply to them.
- **Port-feature skill**: step 3 says to name types from the glossary and the suffix list, translating the reference's names, with the examples `SymptomModal` → `SymptomSheet` and `TimelineEvents` → `PetEventsSection`.
- **Lint**: the conventions script gets one more check: every type conforming to `View` in `KiwiFeatures` and `KiwiDesign` has a name ending in an allowed suffix. It has no exceptions, and it doesn't check the glossary's words to avoid.
- **Renames now**:
  - `Route.pet` → `.petOverview`, `Route.petProfile` → `.petDetails`, `Route.record(petID:recordID:)` → `.petEvent(petID:petEventID:)`.
  - Placeholder titles become "Pet overview", "Details" and "Pet event details", and the "Pet profile" preview becomes "Pet details".
  - `HouseholdMembersModel` → `MembersModel`, its tests included.
  - `BrandLogo` → `LogoImage`, `AppIdentity` → `AppNameLabel`, `AppRoot` → `RootView`, `AppShell` → `MainTabView`. The `AppShell` folder keeps its name, since it's the area, not the type.
  - Doc comments and docs that name the old types (`ios/CONVENTIONS.md`, the port-feature skill) are updated. Finished specs in `tracker/` keep the names they shipped with.
- **Migration plan**: "Add a pet and edit its profile" → "Add a pet and edit its details", "Pet overview page" → "Pet overview screen", "Event detail screen" → "Pet event details screen".
- **Reference names not yet ported** follow the rule when their feature is ported, not in this change.

## Testing Decisions

- **Seam**: the conventions script under `make lint` is the only new check. It must fail on a `View` without an allowed suffix (try a throwaway one) and pass on the renamed code.
- **Behavior unchanged**: `make build` and `make test` pass with the renamed types. The existing suites (`MembersModelTests`, renamed from `HouseholdMembersModelTests`, `PetsScreenTests`, `HouseholdModelTests` and the rest) are the evidence, with no new tests.
- **Previews**: the tab placeholders, and the Pets stack pushed to the overview and the details, show the new titles, light and dark.
- **Simulator**: sign in on the local stack and walk the four tabs. Nothing should change except the placeholder titles. No migration, so the shared project needs no change.

## Out of Scope

- Renaming reference names that aren't ported yet (`QuickLog`, `PetActivityCard`, `CalendarItemRow` and others). Each port does it.
- Checking the glossary's words to avoid in code.
- Database names (`pet_events`, `calendar_events`): the schema is shared with the Expo app.
- Web naming, which comes with Phase 8's `CONVENTIONS.md`.
