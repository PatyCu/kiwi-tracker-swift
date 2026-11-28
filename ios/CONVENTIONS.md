# iOS conventions

The rules the iOS app's code follows, and how they're checked. Why it's built
this way: the [architecture principles](../docs/architecture.md) and the
[ADRs](../docs/adr/).

## Stack

- Swift 6 with strict concurrency; app and feature code default to `MainActor`
  isolation.
- SwiftUI, Observation (`@Observable`), `async`/`await`. No Combine, no
  third-party UI or state libraries.
- Minimum iOS 26, iPhone, portrait.
- supabase-swift v2 is the only production dependency. Row types are generated
  from the schema as plain `Codable` structs (`make db-types`).
- Tests use Swift Testing.

## Modules

The app target holds only the `@main` app, the root composition, assets and
Info.plist. The code lives in the local package `KiwiKit`:

| Target         | Holds                                                                                                     | May import                 |
| -------------- | --------------------------------------------------------------------------------------------------------- | -------------------------- |
| `KiwiDomain`   | Models, pure rules, validation, store protocols.                                                          | Foundation                 |
| `KiwiData`     | The Supabase client, one store per domain concept implementing the domain protocols, row mapping, caches. | `KiwiDomain`, Supabase     |
| `KiwiDesign`   | Palette, typography, shared components.                                                                   | SwiftUI                    |
| `KiwiFeatures` | One folder per product area, with `UI`, `State` and `Forms` as it needs them.                             | `KiwiDomain`, `KiwiDesign` |

- Only `KiwiData` imports Supabase, so features never see a row type or the
  client, and `KiwiDomain` imports only Foundation (`make lint` checks both).
- `KiwiDomain`'s time-dependent rules take `now` and a `Calendar` as input.
- A `KiwiFeatures` folder doesn't reach into another's `State` or `Forms`:
  shared needs move to `KiwiDomain` or `KiwiDesign`, or `RootView` hands them in.
- The app target builds the live stores and models once and puts them in the
  SwiftUI environment. Previews and tests use in-memory stores with fixture
  data.

## UI

- Native SwiftUI components for platform chrome (tabs, navigation, sheets,
  forms, pickers, alerts). UIKit only where SwiftUI has no equivalent, wrapped
  in one view.
- Colors come from `KiwiDesign`'s `Palette`, each with a light and a dark value
  (`make lint` flags literals). Text uses Dynamic Type text styles.
- Copy matches the reference app verbatim, except that copy naming a domain
  concept or a UI piece uses its [GLOSSARY.md](../GLOSSARY.md) term or its
  name here: "Kiwi's details", "Edit details", "Pet event details", "Add pet
  event".
- A UI type is named `<glossary term><suffix>`, never after the reference's
  type (`make lint` checks the suffix of every `View` in `KiwiFeatures` and
  `KiwiDesign`):

  | Suffix    | Kind of piece                                                      |
  | --------- | ------------------------------------------------------------------ |
  | `Screen`  | A tab's root or a pushed screen                                    |
  | `Sheet`   | A sheet (the reference's `Modal`)                                  |
  | `Section` | A titled group in a screen                                         |
  | `Header`  | A section's title row                                              |
  | `Card`    | A boxed tile                                                       |
  | `Row`     | One line of a list                                                 |
  | `Field`   | One form input                                                     |
  | `Picker`  | A choice made with a SwiftUI `Picker`                              |
  | `Button`  | A button                                                           |
  | `Label`   | An icon with text                                                  |
  | `Image`   | An image                                                           |
  | `View`    | Only the app's containers and the loading and load-error stand-ins |

  State and form models end in `Model` and `Form`. An entity's attributes are
  its details (`PetDetailsScreen`, `PetEventDetailsScreen`). Types, routes and
  copy name the kind of Event: Pet event or Calendar event, never "event"
  alone. `PetSelector` sets the Pets tab's selected Pet; `PetPicker` sets a Pet
  event's or a Calendar event's Pet.
- Every screen has `#Preview`s for its loaded, empty, loading and error states,
  using `KiwiFeatures/PreviewSupport`.

## Tests

Tests apply the principle that
[tests protect what the specs promise](../docs/architecture.md#code):

- What reaches a store, auth or the server is behavior too. Doubles stand in
  only at those boundaries, never inside the unit.
- No assertions on constants, default values, literal copy or pass-throughs.
  Copy built by logic is tested for its branch, not its words: an error is
  shown, or two branches' messages differ, so swapped wording goes uncaught.
  Identifiers the developer acts on, such as xcconfig keys, aren't copy.
- One behavior, one test, at the lowest layer that can show it. A form checks
  that invalid details block Save; the invalid cases live in the domain tests.
- A suite is named after the Swift unit it tests, and a test after the spec
  behavior it checks, in words.
- Code, tests and their comments never mention the reference app.

| Target         | What                                                             | With                                              |
| -------------- | ---------------------------------------------------------------- | ------------------------------------------------- |
| `KiwiDomain`   | Every rule, with the behaviors its spec lists.                   | No mocks                                          |
| `KiwiData`     | Row ↔ model and error mapping, Session restore and clearing.     | Stub JSON payloads, in-memory Session storage     |
| `KiwiFeatures` | Model state transitions: load, retry, a failed save keeps input. | In-memory stores                                  |

KiwiKit's tests run outside the app, so the Keychain refuses them
(`errSecMissingEntitlement`): code that touches it is checked on the simulator.

## Project

- Edit the Xcode project with Xcode's synchronized folders: add files on disk,
  and don't hand-edit `project.pbxproj` unless a build setting requires it.
- The `Debug` configuration uses the local stack and `Debug Shared` the shared
  project. A configuration's name starts with `Debug` because Xcode builds local
  packages unoptimized and with `DEBUG` only for configurations named that way.
- Only publishable keys go in the `ios/Config` xcconfig files.

## Checks

Run from `ios/`. KiwiKit builds only for iOS, so `swift build` fails; build and
test it through `make`:

```bash
make lint    # swift format lint --strict, plus scripts/check-conventions.sh
make build   # xcodebuild, warnings are errors
make test    # Swift Testing for KiwiKit; prints compile errors, failing tests and the counts
make test ONLY=KiwiFeaturesTests/PetsModelTests     # one suite (or Target/Suite/test)
```
