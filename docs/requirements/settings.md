# Settings and Appearance

### SET-001: Settings sections come in a fixed order
Status: draft
Migration: changed
Source: src/modules/settings/ui/SettingsScreen.tsx

Settings shows Appearance, then Household, then Members, then Account, where the reference shows Members inside the Household section.

### SET-002: Appearance offers System, Light and Dark
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

Settings' Appearance section offers "System", "Light" and "Dark", with the selected one marked.

### SET-003: Every launch starts at System
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

The app starts every launch with System selected, whatever was chosen before.

### SET-004: An Appearance choice applies at once, everywhere
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

Choosing Light or Dark immediately switches every screen and sheet, including sign-in and the waiting screens.

### SET-005: System follows the device
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

With System selected, including after going back to it from Light or Dark, the app switches when the device switches between light and dark.

### SET-006: The Appearance choice survives sign-out
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

Signing out and signing in again, as any Account, keeps the Appearance choice until the app quits.

### SET-007: The status bar follows the Appearance
Status: draft
Migration: same
Source: src/app/_layout.tsx

The status bar's text is light while the app shows Dark and dark while it shows Light.

### SET-008: Appearance options are read as one choice
Status: draft
Migration: same
Source: src/modules/appearance/ui/AppearanceSection.tsx

VoiceOver reads each Appearance option as a radio button, checked on the selected one.
