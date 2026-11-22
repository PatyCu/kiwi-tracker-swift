# `kiwitracker://` URL handling that nothing uses

Status: done

The iOS app opens `kiwitracker://` URLs to tabs, pets, profiles and records
(`AppDestination(url:)` in `KiwiFeatures/AppShell/Route.swift`, `onOpenURL` in
`AppShell.swift`, the scheme in `ios/KiwiTracker/Info.plist`), with each parent
screen under the last one so Back works.

Found while reviewing `docs/architecture.md`, which said this matched the Expo
app. In the reference (`.reference/kiwi-tracker`, `c6db92f`):

- `app.json` sets `"scheme": "kiwitracker"`, so Expo Router accepts a URL for
  every route automatically, and `+not-found.tsx` answers any other.
- Nothing produces these URLs: no notifications, sharing or emails link into
  the app.
- No stack sets `initialRouteName`, so a URL opens the screen without its parent
  screens underneath, unlike the iOS app.

To decide: remove the URL handling (nothing uses it now), or keep matching the
reference's linkable routes, and then whether parent screens go underneath.

## Comments

Decided: remove the URL handling and keep `Route` and the per-tab stacks for
in-app navigation. Nothing produces these URLs, and the reference only accepts
them as a side effect of Expo Router, not as a feature. When notifications or
sharing need links, add handling built for the links they produce. No ADR:
adding it back is cheap, and no screen or flow changes.
