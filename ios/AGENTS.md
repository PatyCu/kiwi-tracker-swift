# iOS app agent guidance

The native iOS app. Read the root `AGENTS.md` first; this file adds the iOS
stack and checks. Architecture: `docs/architecture.md#ios-app`.

## Stack and conventions

- Swift 6 with strict concurrency, SwiftUI, Observation (`@Observable`), `async`/`await`. No Combine, no third-party UI or state libraries.
- Minimum iOS 26, iPhone, portrait.
- Code lives in the local package `KiwiKit`: `KiwiDomain` (models, pure rules, store protocols), `KiwiData` (Supabase), `KiwiDesign` (palette, shared components), `KiwiFeatures` (one folder per product area). The app target only composes them.
- Only `KiwiData` imports Supabase, and `KiwiDomain` imports only Foundation (`make lint` checks both). `KiwiDomain`'s time-dependent rules take `now` and a `Calendar` as input.
- Use native SwiftUI components for platform chrome (tabs, navigation, sheets, forms, pickers, alerts). A custom control needs a reason in `docs/architecture.md#native-components-and-parity`.
- Colors come from `KiwiDesign`'s `Palette` (`make lint` flags literals). Text uses Dynamic Type text styles.
- Copy is matched verbatim to the reference app.
- Every screen has `#Preview`s for its loaded, empty, loading and error states, using `KiwiFeatures/PreviewSupport`.
- Edit the Xcode project with Xcode's synchronized folders: add files on disk, don't hand-edit `project.pbxproj` unless a build setting requires it.

## Checks

Run from `ios/`:

```bash
make lint    # swift format lint --strict, plus scripts/check-conventions.sh
make build   # xcodebuild, warnings are errors
make test    # Swift Testing for KiwiKit; prints the pass and fail counts
```

- Prefer the Xcode MCP server (`.mcp.json`) or the simulator tools for builds, previews and launches when available; `make` is the fallback and what wrap-up runs.
- `make run` builds the `KiwiTracker` scheme (local stack) and opens it on the iPhone 17 Pro on the newest iOS runtime, by UDID; `make run-shared` does the same with `KiwiTracker Shared`, for the developer's check on the shared project. Target simulators by UDID, never `booted`: the developer may have other simulators open.
- To tap through a flow, use the Xcode MCP device-interaction tools on that iOS 27 simulator (they don't support iOS 26); they hand the taps to a subagent that loads the `device-interaction` skill.
