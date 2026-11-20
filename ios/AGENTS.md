# iOS app agent guidance

The native iOS app. Read the root `AGENTS.md` first; this file adds the iOS
stack and checks. Architecture: `docs/architecture.md#ios-app`.

## Stack and conventions

- Swift 6 with strict concurrency, SwiftUI, Observation (`@Observable`), `async`/`await`. No Combine, no third-party UI or state libraries.
- Minimum iOS 26, iPhone, portrait.
- Code lives in the local package `KiwiKit`: `KiwiDomain` (models, pure rules, store protocols), `KiwiData` (Supabase), `KiwiDesign` (palette, shared components), `KiwiFeatures` (one folder per product area). The app target only composes them.
- Only `KiwiData` imports Supabase. `KiwiDomain` imports only Foundation, and its time-dependent rules take `now` and a `Calendar` as input.
- Use native SwiftUI components for platform chrome (tabs, navigation, sheets, forms, pickers, alerts). A custom control needs a reason in `docs/architecture.md#native-components-and-parity`.
- Colors come from `KiwiDesign` palette tokens, never literals. Text uses Dynamic Type text styles.
- Copy is matched verbatim to the reference app.
- Every screen has `#Preview`s for its loaded, empty, loading and error states, using `KiwiFeatures/PreviewSupport`.
- Edit the Xcode project with Xcode's synchronized folders: add files on disk, don't hand-edit `project.pbxproj` unless a build setting requires it.

## Checks

Run from `ios/`:

```bash
make format-check   # swift format lint --strict
make build          # xcodebuild, warnings are errors
make test           # Swift Testing for KiwiKit
```

- Prefer the Xcode MCP server (`.mcp.json`) or the simulator tools for builds, previews and launches when available; `make` is the fallback and what wrap-up runs.
- When validating in the simulator, open the in-app simulator panel before building or launching, so the developer can watch and check the app there.
- Run the app on the local stack with the `KiwiTracker` scheme. The `KiwiTracker Shared` scheme is for the developer's check on the shared project.
