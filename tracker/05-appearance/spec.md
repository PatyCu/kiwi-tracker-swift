# Appearance setting in Settings (KIW-41)

Status: done

## Problem Statement

iOS always follows the device's light or dark setting, with no way to choose. The reference app's Settings lets a person pick System, Light or Dark for the app.

## Solution

Settings gains an **Appearance** section, first, above Household, with three rows: "System", "Light" and "Dark", each with an icon and a radio button, the selected one filled. The choice applies at once to the whole app and lasts until the app quits; every launch starts at System, as in the reference.

## User Stories

1. As a person using the app, I want to choose System, Light or Dark in Settings, so that the app looks the way I like regardless of the device's setting.
2. As a person using the app, I want System selected by default, so that the app follows my device until I choose otherwise.
3. As a person using the app, I want the selected choice marked, so that I can see which one is active.
4. As a person using the app, I want my choice to apply immediately, so that I see the result without leaving Settings.
5. As a person using the app, I want the choice to apply everywhere: the tabs, Sign in, the waiting and no-household screens, and sheets, so that the app never mixes light and dark.
6. As a person using the app on System, I want the app to switch when my device switches between light and dark, so that System really follows the device.
7. As a person who chose Light or Dark, I want picking System again to go back to following the device, so that the choice is never stuck.
8. As a person who signs out and signs in again, possibly as another Account, I want the choice kept until the app quits, so that it belongs to the device, not to an Account.
9. As a person relaunching the app, I want it to start at System, matching the reference app.
10. As a person using VoiceOver, I want each row read with its name and whether it's selected, so that I hear the same information.
11. As a person using Dynamic Type, I want the section to scale like the rest of Settings.

## Implementation Decisions

- **Glossary**: none. Appearance is a device setting, not domain language.
- **Choice**: an `Appearance` value with the cases system, light and dark, labelled "System", "Light" and "Dark" in that order, verbatim from the reference.
- **State**: held in memory at the app root (`AppRoot`, above the Session, as the reference's provider sits above its Session provider), so it covers the sign-in-unavailable, Sign in, waiting, no-household and tab screens and survives sign-out within a launch. Applied there with `.preferredColorScheme`, System being `nil`. Settings reads and changes it through the environment.
- **No persistence and no KiwiData**: nothing is saved on the device or sent to Supabase; remembering the choice is logged in `tracker/after-parity.md`.
- **Settings**: a native `Form` section titled "Appearance" first, above Household, with one row per choice: its icon and name, then a radio button, filled in kiwi when selected; no footer. The reference's radio buttons stay, with an icon added, as [ADR 0009](../../docs/adr/0009-radio-buttons-for-the-appearance-choice.md) records; a prototype compared them with a native checkmark list, segmented control and menu row (branch `prototype/appearance-variants`).

## Testing Decisions

- Tests check what a person sees, never how a view is built. The reference has no rule tests for Appearance, so there are none to port and no unit tests are added: mapping System to `nil` would only test SwiftUI.
- **Settings**: `#Preview`s with each choice selected, light and dark, as the other Settings sections have.
- **Simulator**: walk all three choices, System following the device's light/dark switch, going back to System from Light and from Dark, the choice applying to a sheet and surviving sign-out and sign-in, and System again after relaunch.

## Out of Scope

- Remembering the choice across launches (after parity).
- Any per-Account or per-Household appearance.
- Changing the palette itself.

## Further Notes

- SwiftUI may not return to the device's setting when `.preferredColorScheme` changes from light or dark back to `nil` in an already presented window. If the simulator walk shows that, set the window's interface style instead, keeping the same `Appearance` value at the root.
- This is the last feature in Phase 2; once it's ticked off, run the phase's exit check.
- Validate on the local stack signed in as a seeded Account, then on the shared project with `make run-shared` for the developer's check.
