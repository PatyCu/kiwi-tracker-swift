# Migration plan

Moving Kiwi Tracker from the Expo app to a native iOS app, a React web app and
a backend owned by this repo. Until iOS parity (Phase 7) this file is the
roadmap, and `tracker/` holds each feature's tickets and the open bugs
([how](agents/issue-tracker.md)). Linear isn't used until then.

**Current phase:** 3 — Pets

## How to use this file

- One checklist line per feature. When work on it starts, it gets a folder under `tracker/` with its tickets, linked from that line.
- Tick a feature off in the same commit that finishes its last ticket.
- `KIW-n` is the reference feature in Linear being ported.
- Work the phases in order, top feature first; a phase is done when every feature is ticked off and its exit check passes, on evidence its features' validation already gathered; walk only what they didn't cover.
- Update **Current phase** when a phase finishes.
- Add a feature only for work that's decided.
- Log bugs in `tracker/bugs/` when found; they come before the next feature.

## Ground rules

- The Expo app is the reference until Phase 9: match it, don't redesign.
- Whatever we need from the Expo app is copied from `.reference/kiwi-tracker`, never used in place.
- Each port ships with its rules' tests ported case for case.

## Phase 0 — Decisions and setup

- [x] Agent guidance, skills, tooling config and architecture doc
- [x] Pinned reference copy: `git clone --no-hardlinks ../kiwi-tracker .reference/kiwi-tracker`, detached at `c6db92f`, `origin` removed
- [x] Shared Supabase project with the Expo app
- [x] Expo app frozen and its repo untouched; retired after parity
- [x] Monorepo (iOS, web, backend in this repo) confirmed
- [x] Parity policy (same UX, native chrome) confirmed
- [x] supabase-swift dependency approved
- [x] Bundle ID: `com.patycu.kiwitracker`
- [x] iOS 26 minimum confirmed
- [x] Linear paused until iOS parity, then back to the existing Kiwi Tracker project
- [x] GitHub repo created (public) and `main` pushed

**Exit:** every architecture decision above is recorded in [`docs/adr/`](adr/).

## Phase 1 — Foundation

- [x] `supabase/` (migrations, seed, config) copied here from `.reference/kiwi-tracker`
- [x] Local stack runs from this repo; `supabase db push --remote --dry-run` lists nothing
- [x] Xcode project, `KiwiKit` package with its four targets, Swift 6, warnings as errors
- [x] `KiwiTracker` and `KiwiTracker Shared` schemes with their xcconfigs
- [x] Supabase client and generated Swift row types (`make db-types`)
- [x] Palette, app icon and logo in `KiwiDesign`
- [x] Shared components: load/error state with Retry, placeholder card, section header
- [x] App shell: four tabs with placeholders, `Route`
- [x] `make format-check`, `make build`, `make test` pass

**Exit:** the app launches on the simulator against the local stack and shows the four tabs.

## Phase 2 — Accounts and households

- [x] Sign in with email and password (KIW-46)
- [x] Show or hide the password (KIW-98)
- [x] Sign out from Settings — [tracker](../tracker/01-sign-out/)
- [x] Waiting for the household: loading, error with Retry, no-household screen (KIW-89) — [tracker](../tracker/02-waiting-for-household/)
- [x] Household alias on Today, Pets and Settings (KIW-88) — [tracker](../tracker/03-household-alias/)
- [x] Household members by display name in Settings (KIW-91) — [tracker](../tracker/04-household-members/)
- [x] Appearance setting: System, Light, Dark (KIW-41) — [tracker](../tracker/05-appearance/)

**Exit:** every seeded account signs in and sees its own household, or the no-household screen.

## Phase 3 — Pets

- [x] Pets list and multi-pet support (KIW-22) — [tracker](../tracker/06-pets-list/)
- [x] Consistent UI names from the glossary and iOS terms — [tracker](../tracker/07-ui-names/)
- [ ] No pets yet card on Today and Pets (KIW-84) — [tracker](../tracker/08-no-pets-card/)
- [ ] Add a pet and edit its details (KIW-23)
- [ ] Pet selector cards with editing (KIW-25)
- [ ] Pet photo from the library: 512px upload, signed links, on-device cache (KIW-24)
- [ ] Pet overview screen (KIW-26)

**Exit:** pets and photos added on iOS show up in the Expo app, and the reverse.

## Phase 4 — Pet event logging

- [ ] Log a symptom (KIW-27)
- [ ] Log a diet change (KIW-28)
- [ ] Log an Other pet event (KIW-29)
- [ ] Quick Log (KIW-30)
- [ ] Date and time pickers (KIW-31)
- [ ] Current diet from diet history (KIW-32)
- [ ] Per-pet timeline (KIW-34)
- [ ] Pet event details screen (KIW-35)
- [ ] Edit a pet event (KIW-33)
- [ ] Change a pet event's date and time (KIW-36)
- [ ] Delete a pet event (KIW-37)

**Exit:** every pet event type round-trips between iOS and the Expo app with the same fields.

## Phase 5 — Health status and Today

- [ ] Green, amber and red status per pet (KIW-38)
- [ ] Today summary across all pets (KIW-39)

**Exit:** for the seeded data, Today matches the Expo app line for line.

## Phase 6 — Calendar

- [ ] Calendar tab: compact month, selected day's list, Monday-first (KIW-102)
- [ ] Add a calendar event (KIW-20)
- [ ] Open a calendar event's details (KIW-108)
- [ ] Filter by pet and calendar event type (KIW-109)
- [ ] Mobile tweaks: "‹ Month ›", deselect day, "+" in the month card (KIW-110)
- [ ] Upcoming care, next 7 days, on Today and Up next (KIW-11)

**Exit:** the Calendar matches the Expo app for every seeded account.

## Phase 7 — iOS parity sign-off and release

- [ ] Full side-by-side walkthrough of every screen and flow; differences fixed or confirmed as intentional
- [ ] VoiceOver and Dynamic Type pass on every screen
- [ ] Fixed Expo bugs re-checked on iOS (KIW-5, KIW-6, KIW-7, KIW-99, KIW-100, KIW-105)
- [ ] TestFlight build (iOS part of KIW-21)
- [ ] The household uses the native app instead of the Expo iOS build
- [ ] Linear resumed in the Kiwi Tracker project: ported features, open bugs and [after-parity improvements](../tracker/after-parity.md) reflected there

**Exit:** the developer signs off iOS parity.

## Phase 8 — Web app

- [ ] `web/` with React, TypeScript and supabase-js, its stack recorded as an ADR, its own `AGENTS.md` and `CONVENTIONS.md`
- [ ] Domain rule cases moved to shared JSON fixtures, read by both test suites
- [ ] Phases 2–6 ported to web, including wide layouts (sidebar navigation, month grid)
- [ ] Screen-reader states on web (KIW-104)
- [ ] Web deployed (web part of KIW-21)

**Exit:** the developer signs off web parity.

## Phase 9 — Retire the Expo app

- [ ] The developer turns off the Expo iOS build and web deploy, and archives its repo, if they choose to
- [ ] Additive-only schema rule lifted in `AGENTS.md`
- [ ] "Reference implementation" wording removed from docs

**Exit:** nothing in this repo depends on `.reference/kiwi-tracker`, and it's deleted.
