---
name: drive-simulator
description: Tap, type and screenshot the iOS app on the simulator with the Xcode MCP device-interaction tools. Use when a flow must be walked in the running app (signing in, checking a screen, light and dark), usually from a subagent handed the walk.
---

# Drive the simulator

Walks a flow in the app that `make run` or `make run-shared` (in `ios/`) already installed and opened. Building and installing stay with those targets.

## 1. Start the session

- Get the UDID with `make -s -C ios simulator-id`: the iPhone 17 Pro on the newest runtime. Device interaction works only on iOS 27, and the developer may have other simulators open, so always pass this UDID.
- Call `DeviceInteractionStartSession` with that UDID as `deviceIdentifier` and a Title Case `sessionIdentifier`. Keep the returned session key.

## 2. Interact

Each `DeviceInteractionSynthesize` call takes the session key and one `interactionCommand`, then returns paths to a screenshot and a UI hierarchy.

- **Look**: call it with no `interactionCommand`. Read the hierarchy for positions; take every coordinate from the latest hierarchy.
- **Tap**: `t X Y`.
- **Type**: tap the field, then `sender keyboard kbd <text>`. This is the only typing command the tool accepts.
- **Dark or light**: `xcrun simctl ui <UDID> appearance dark` (or `light`).
- **Full-resolution screenshot**: `xcrun simctl io <UDID> screenshot <path>`, saved to the scratchpad.

## 3. App specifics

- Seeded accounts and their password are in `supabase/seed.sql`, header comment.
- When the app opens already signed in and the walk needs another account, sign out first: Settings, then Sign out (no confirmation).
- After sign-in iOS may show its "Save Password?" sheet over the app: tap Not Now.

## 4. Finish

Done when every step of the walk is reported, with what each screen shows and the screenshot paths, and the simulator is left as found: signed out if you signed in, light mode, and the session closed with `DeviceInteractionEndSession`.
