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
  shared needs move to `KiwiDomain` or `KiwiDesign`, or `AppRoot` hands them in.
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
  concept uses its [GLOSSARY.md](../GLOSSARY.md) term.
- Every screen has `#Preview`s for its loaded, empty, loading and error states,
  using `KiwiFeatures/PreviewSupport`.

## Tests

| Target         | What                                                              | With                   |
| -------------- | ----------------------------------------------------------------- | ---------------------- |
| `KiwiDomain`   | Every rule, with the reference's test cases and names.             | No mocks               |
| `KiwiData`     | Row ↔ model and error mapping.                                    | Recorded JSON payloads |
| `KiwiFeatures` | Model state transitions: load, retry, a failed save keeps input.  | In-memory stores       |

## Project

- Edit the Xcode project with Xcode's synchronized folders: add files on disk,
  and don't hand-edit `project.pbxproj` unless a build setting requires it.
- The `Debug` configuration uses the local stack and `Debug Shared` the shared
  project. A configuration's name starts with `Debug` because Xcode builds local
  packages unoptimized and with `DEBUG` only for configurations named that way.
- Only publishable keys go in the `ios/Config` xcconfig files.

## Checks

Run from `ios/`:

```bash
make lint    # swift format lint --strict, plus scripts/check-conventions.sh
make build   # xcodebuild, warnings are errors
make test    # Swift Testing for KiwiKit; prints the pass and fail counts
make test ONLY=KiwiFeaturesTests/TodayScreenTests   # one suite (or Target/Suite/test)
```
