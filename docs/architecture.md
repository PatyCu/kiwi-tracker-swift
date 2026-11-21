# Architecture

Kiwi Tracker is a pet care and health tracker for a household: log symptoms,
diet changes and other events per pet, plan care in a calendar, and see an
at-a-glance health status across all pets. This repository holds the native
iOS app (Swift, SwiftUI) and, as their work starts, the React web app and the
Supabase backend.

The Expo app ([PatyCu/kiwi-tracker](https://github.com/PatyCu/kiwi-tracker))
is the **reference implementation**: the native iOS app and the React web app
match its capabilities, flows, copy and branding.

## System overview

```mermaid
flowchart LR
  subgraph Clients
    IOS["iOS app<br/>Swift · SwiftUI"]
    WEB["Web app<br/>React · TypeScript"]
    EXPO["Expo app<br/>(reference, frozen, retired after parity)"]
  end

  subgraph Supabase["Supabase (shared project, EU West 3)"]
    AUTH["Auth<br/>email + password, sign-up off"]
    REST["PostgREST API"]
    DB[("Postgres<br/>RLS per household")]
    STORAGE["Storage<br/>pet-photos (private)"]
  end

  IOS -- supabase-swift --> AUTH & REST & STORAGE
  WEB -- supabase-js --> AUTH & REST & STORAGE
  EXPO -. supabase-js .-> REST
  REST --> DB
  STORAGE -. policies .-> DB
```

- **One backend, thin clients.** Every client talks to Supabase directly. There
  is no custom API server: row-level security in Postgres is the authorization
  layer, and `private.is_household_member()` / `private.accessible_pet_ids()`
  stay the single place that decides who sees what.
- **Online-only.** Household data lives in Supabase. Clients keep only the
  session and a cache of pet photos. No offline writes, no sync engine.
- **The schema is the contract.** Migrations are the source of truth; each
  client generates its row types from the schema (`supabase gen types`,
  `--lang swift` and `--lang typescript`) and maps rows to its own domain
  model.
- **Domain rules run on the client.** Health status, current diet, timeline and
  calendar grouping depend on the device's "now" and time zone, so each client
  implements them. The iOS and web suites check them against the same cases
  (see [Keeping clients consistent](#keeping-clients-consistent)).

### Repository layout

```text
kiwi-tracker-swift/
├── AGENTS.md, CLAUDE.md     # agent guidance shared by every part of the repo
├── docs/                    # architecture, Supabase backend, migration plan
├── ios/                     # native iOS app (own AGENTS.md)
├── web/                     # React web app, when its work starts (own AGENTS.md)
└── supabase/                # migrations, seed, local stack config
```

`web/` is added when its work starts; no empty folders before that.

## iOS app

### Platform and language

| Choice              | Value                                       | Why                                                                                                             |
| ------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Minimum iOS         | 26.0                                        | Current native look (Liquid Glass tab and navigation bars) with no fallbacks.                                   |
| Bundle ID           | `com.patycu.kiwitracker`                    | Fixed once the first TestFlight build exists.                                                                   |
| Devices             | iPhone, portrait                            | Same as the Expo app's iOS build.                                                                               |
| Language            | Swift 6, strict concurrency                 | Data races are compile errors. App and feature code default to `MainActor` isolation.                           |
| UI                  | SwiftUI                                     | UIKit only where SwiftUI has no equivalent, wrapped in one view.                                                |
| State               | Observation (`@Observable`)                 | Native, no third-party state library.                                                                           |
| Async               | `async`/`await`, structured concurrency     | No Combine in new code.                                                                                         |
| Backend SDK         | [supabase-swift](https://github.com/supabase/supabase-swift) | Official SDK for Auth, PostgREST and Storage. The only production dependency.                    |
| Row types           | Generated from the schema                   | Plain `Codable` structs. Later CLIs generate supabase-swift v3 types; the app stays on stable v2 until v3 is released. |
| Tests               | Swift Testing (+ XCTest for UI tests)       | Bundled with Xcode.                                                                                             |
| Format and lint     | `swift format` (bundled with the toolchain) | No extra tool to install.                                                                                       |
| Project             | Xcode project + one local Swift package     | Xcode's synchronized folders keep the project file small; the package enforces module boundaries.               |

### Modules

The Xcode app target is thin: the `@main` app, the root composition, assets
and Info.plist. Everything else is in a local Swift package, `ios/KiwiKit`,
split into four targets. The compiler enforces the dependency direction, the
way lint did in the Expo app.

```mermaid
flowchart TD
  APP["KiwiTracker (app target)<br/>composition root"] --> FEAT
  APP --> DATA
  FEAT["KiwiFeatures<br/>screens, view models, forms"] --> DOMAIN
  FEAT --> DESIGN
  DATA["KiwiData<br/>Supabase stores, row mapping, photo cache"] --> DOMAIN
  DATA --> SB["supabase-swift"]
  DESIGN["KiwiDesign<br/>palette, components"]
  DOMAIN["KiwiDomain<br/>models, rules, store protocols"]
```

| Target         | Holds                                                                                                                                                                   | May import                       |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `KiwiDomain`   | Models, pure rules, validation, store protocols.                                                          | Foundation                 |
| `KiwiData`     | The Supabase client, one store per table or bucket implementing the domain protocols, row mapping, the pet photo cache. | `KiwiDomain`, Supabase     |
| `KiwiDesign`   | Palette, typography, shared components.                                                                   | SwiftUI                    |
| `KiwiFeatures` | One folder per product area, each with `UI`, `State`, `Forms`.                                            | `KiwiDomain`, `KiwiDesign` |

Rules that follow from this:

- Only `KiwiData` imports Supabase. Features never see a row type or the client.
- `KiwiDomain` has no UI and no I/O, so its rules are tested without mocks.
  Time-dependent rules take `now` (and a `Calendar` for the time zone) as input.
- Feature folders mirror the Expo app's `src/modules`, so a capability is found
  in the same place in both. Within `KiwiFeatures`, a folder doesn't reach into
  another's `State` or `Forms`; shared needs move to `KiwiDomain` or
  `KiwiDesign`, or `AppRoot` hands them in.
- No `Utils`, `Helpers` or `Common` folders.

### Data flow

```mermaid
sequenceDiagram
  participant V as SwiftUI view
  participant M as @Observable model (KiwiFeatures)
  participant S as Store protocol (KiwiDomain)
  participant D as Supabase store (KiwiData)
  participant API as Supabase

  V->>M: task / user action
  M->>S: await petStore.pets(in: householdID)
  S->>D: (live implementation)
  D->>API: PostgREST select
  API-->>D: rows (RLS-filtered)
  D-->>M: [Pet] or PetStoreError
  M-->>V: state = .loaded([Pet]) / .failed(error)
```

- **Stores** (`KiwiData`) are stateless: typed inputs, typed outputs, typed
  errors. They map rows to domain models and back.
- **Models** (`KiwiFeatures/*/State`) are `@MainActor @Observable` classes that
  hold what screens show and expose operations. They replace the Expo app's
  providers, one for one.
- **Load state** is a single enum rendered by one shared view with Retry.
  Retry reloads only what failed, as in the Expo app.
- **Dependency injection** goes through the SwiftUI environment: the app target
  builds the live stores and models once and puts them in the environment.
  Previews and tests use in-memory stores with fixture data.
- **Writes** never drop user input on failure: the form keeps its values and
  shows the error.

### Navigation

Each tab has its own `NavigationStack` with a typed path of `Route` values, and
the `kiwitracker://` URLs keep the Expo app's scheme and paths, opening the
tab and its path with parent screens underneath so Back works. The root view
waits for the session and the household before it shows the tabs, as the Expo
app's root layout does.

Routes carry IDs, never objects, so required context stays explicit (pet
operations receive `petID`), as in the Expo app.

### Native components and parity

"Same UX" means the same information architecture, flows, rules, copy,
branding and empty, loading and error states. Platform chrome comes from
native components, so on iOS it looks and behaves like iOS.

Exception: the Calendar's compact month (Monday-first weeks, "‹ Month ›"
header, tapping the selected day deselects it, per-day markers) is a custom
SwiftUI grid built on `Calendar`. `UICalendarView` can't show that header or
deselect a day, so it can't match the reference.

### Branding

The Expo palette becomes color sets in `KiwiDesign`, each with its light and
dark value. Text uses the system font with Dynamic Type, as the Expo app does
on iOS.

### Session and photos

- Accounts sign in with email and password through Supabase Auth; public
  sign-up stays off. supabase-swift keeps the session in the Keychain (the
  Expo app used AsyncStorage) and refreshes tokens while the app is active.
- Unlike AsyncStorage, the Keychain keeps the session when the app is
  deleted, so reinstalling stays signed in; sign out to see sign-in again.
- Pet photos are shown through short-lived signed links, and downloaded
  images are cached on the device under their storage path, so a new link
  reuses the file. Same behavior as the Expo app on iOS.

### Environments

| Scheme               | Build configuration | Supabase                       | Config                                                                  |
| -------------------- | ------------------- | ------------------------------ | ----------------------------------------------------------------------- |
| `KiwiTracker`        | `Debug`             | Local stack (`supabase start`) | `ios/Config/Local.xcconfig`, committed (local URL and publishable key). |
| `KiwiTracker Shared` | `Debug Shared`      | Shared project                 | `ios/Config/Shared.xcconfig`, git-ignored, same two keys.               |

Each scheme picks its Supabase project through its build configuration. The
second configuration's name starts with `Debug` because Xcode builds local
packages unoptimized and with `DEBUG` only for configurations named that way.
Only publishable keys go in these files. Setting up `Shared.xcconfig`:
[README](../README.md#run).

### Testing and validation

| Layer          | What                                                                                                   | How                                        |
| -------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------ |
| `KiwiDomain`   | Every rule, ported test-for-test from the Expo app's Jest tests.                                       | Swift Testing, no mocks.                   |
| `KiwiData`     | Row ↔ model mapping and error mapping.                                                                 | Swift Testing with recorded JSON payloads. |
| `KiwiFeatures` | Model state transitions (load, retry, save failure keeps input).                                        | Swift Testing with in-memory stores.       |
| Screens        | Every screen has `#Preview`s for loaded, empty, loading and error, used for visual parity checks.      | Xcode previews.                            |
| App            | The change, end to end, on the local stack in the simulator.                                           | Agent in the simulator panel.              |
| Shared project | The developer's single check before anything is committed.                                             | Developer, `KiwiTracker Shared` scheme.    |

## Backend

The Supabase project, schema, RLS rules, storage layout and seed stay as they
are; the native and web apps are new clients of the same backend.

- **Shared project.** All apps use the Expo app's Supabase project: same
  accounts and data, so the household can switch apps at any time.
- **Ownership.** `supabase/` was copied into this repository, and new
  migrations are written only here. The Expo repo keeps its copy untouched;
  the Expo app is frozen, so it never pushes a migration again.
- **Compatibility.** Parity needs no migrations. Until the Expo app is retired,
  any schema change must keep it working: additive changes only.
- **Local first.** Changes are checked on the local stack, then applied to the
  shared project before the developer's check, as today. How:
  [docs/supabase.md](supabase.md).

## Web app

When its work starts: React with TypeScript, Vite, React Router and
supabase-js, in `web/`. It talks to the same Supabase project, has its own
`AGENTS.md`, and follows the same parity rule against the Expo app's web build
(including its wide-screen layouts: sidebar navigation and the month grid).

## Keeping clients consistent

The same rules exist in Swift and TypeScript, so they can drift.

- Domain rule tests are ported case-for-case from the Expo app, with the same
  names, so a rule's cases can be compared side by side.
- When the web app starts, those cases move to shared JSON fixtures in this
  repo that both test suites read, so a rule change updates one file and fails
  both suites until both are fixed.
