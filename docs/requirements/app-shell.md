# App shell

### APP-001: The tabs are Today, Pets, Calendar and Settings, in that order
Status: active
Migration: same
Source: src/app/(tabs)/_layout.tsx

A signed-in Account sees a tab bar with "Today", "Pets", "Calendar" and "Settings", in that order.

### APP-002: Each tab has its icon, filled when selected
Status: active
Migration: same
Source: src/app/(tabs)/_layout.tsx

Today shows a house, Pets a paw, Calendar a calendar and Settings a gear; only the selected tab's icon is filled and its label highlighted.

### APP-003: A signed-in launch opens Today
Status: active
Migration: same
Source: src/app/(tabs)/_layout.tsx

Launching the app with a Session opens the Today tab.

### APP-004: Each tab keeps its place when switching tabs
Status: active
Migration: same
Source: src/app/(tabs)/_layout.tsx

Switching to another tab and back shows the screen the tab was on, not its first screen.

### APP-005: Tapping the selected tab returns to its first screen
Status: active
Migration: same
Source: src/app/(tabs)/pets/_layout.tsx

Tapping the selected tab while it shows a deeper screen goes back to the tab's first screen.

### APP-006: Every tab shows the Kiwi Tracker header
Status: active
Migration: same
Source: src/shared/ui/AppHeader.tsx

Every tab screen has a header with the app logo and "Kiwi Tracker", read by VoiceOver as "Kiwi Tracker".

### APP-007: Launch shows nothing until the stored Session is read
Status: dropped
Reason: Duplicate of AUTH-021.
Migration: same
Source: src/app/_layout.tsx

While the app reads the stored Session at launch it shows an empty screen, so a signed-in Account never sees the sign-in form flash.

### APP-008: Signed out, only sign-in is reachable
Status: active
Migration: changed
Source: src/app/_layout.tsx

Without a Session, the app shows the sign-in form and no tab screen.

### APP-009: Signed in, sign-in is unreachable
Status: active
Migration: same
Source: src/app/_layout.tsx

With a Session, the sign-in form is never shown, and going back from the tabs doesn't return to it.

### APP-010: One Retry reloads everything that failed with the Household
Status: dropped
Reason: Duplicate of HH-023.
Migration: same
Source: src/app/_layout.tsx

Retry on the Household load error also reloads the Pets, their events and the Calendar events, so one Retry is enough to open the app.

### APP-011: A load error reads the same everywhere
Status: dropped
Reason: Duplicate of HH-022.
Migration: same
Source: src/shared/ui/LoadState.tsx

A screen whose data can't load shows "Could not load your data", "Check your connection and try again.", "Your saved data has not been changed." and a "Retry" button.

### APP-012: Loading reads the same everywhere
Status: active
Migration: same
Source: src/shared/ui/LoadState.tsx

A screen waiting for its data shows a spinner with "Loading…", read by VoiceOver as "Loading".

### APP-013: An unknown link shows Page not found
Status: dropped
Reason: No links reach the app (APP-015 dropped).
Migration: same
Source: src/app/+not-found.tsx

A link to a screen that doesn't exist shows "Page not found" with a "Return to Today" link.

### APP-014: Return to Today leaves Page not found
Status: dropped
Reason: No links reach the app (APP-015 dropped).
Migration: same
Source: src/app/+not-found.tsx

"Return to Today" opens Today, or the sign-in form when signed out.

### APP-015: A kiwitracker link opens its screen
Status: dropped
Reason: Nothing creates these links.
Migration: same
Source: app.json

A `kiwitracker://` link whose path matches a screen, such as `kiwitracker://pets/‹id›`, opens the app on that screen.
Note: nothing in the app, its emails or the backend creates such links, and sign-in uses no redirect; a candidate to drop.

### APP-016: The app stays in portrait
Status: active
Migration: same
Source: app.json

The app doesn't rotate to landscape.

### APP-017: The app is for iPhone
Status: active
Migration: same
Source: app.json

The app isn't built for iPad, so on an iPad it runs at iPhone size.

### APP-018: The status bar follows the Appearance
Status: dropped
Reason: Duplicate of SET-007.
Migration: same
Source: src/app/_layout.tsx

The status bar's text is light while the app is dark and dark while it's light, on every screen.

### APP-019: Alerts follow the Appearance
Status: active
Migration: changed
Source: app.json

System alerts, such as save failures and discard confirmations, are dark while the app is dark and light while it's light.
Note: the reference forces dark alerts; fixed.

### APP-020: Tapping outside a sheet closes it as Close does
Status: active
Migration: same
Source: src/shared/ui/modal/ModalSheet.tsx

A sheet has a "Close" button at its top right, and tapping the dimmed area above the sheet does the same as that button.

### APP-021: Discarding changes asks with the same wording everywhere
Status: active
Migration: same
Source: src/shared/platform/dialogs.ts

Closing a form with unsaved changes asks with "Your changes will not be saved.", offering "Keep editing", which keeps the form, and "Discard", which closes it.
