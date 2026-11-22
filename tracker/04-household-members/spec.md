# Household Members in Settings (KIW-91)

Status: done

## Problem Statement

Members can't see who else shares their Household. The reference app's Settings lists the Household's Members by Display name, marking the signed-in Member, while iOS shows only the Household alias.

## Solution

Settings gains a **Members** section, between Household and Account, with one row per Member showing their Display name, sorted by Display name. The signed-in Member's row ends with "(you)". The Members load the first time Settings opens after sign-in, showing "Loading…" meanwhile, or "Could not load the members." with Retry when that fails.

## User Stories

1. As a Member, I want Settings to list my Household's Members, so that I know who shares our pets.
2. As a Member, I want each Member shown by their Display name, never their email, so that the list reads the way our Household talks.
3. As a Member, I want my own row marked "(you)", so that I can tell which one is me.
4. As a Member, I want the Members sorted by Display name, so that the list has a stable, predictable order.
5. As a Member, I want "Loading…" while the Members load, so that I know they're coming.
6. As a Member, I want "Could not load the members." with Retry when they fail to load, so that I can try again without leaving Settings.
7. As a Member, I want a failed Members load to leave the rest of the app working, so that one list never blocks the tabs.
8. As a Member, I want the list not to reload every time I switch back to Settings, so that it doesn't flash "Loading…".
9. As a Member whose Display name was set with stray spaces, I want them gone, so that the list looks clean.
10. As a Member using VoiceOver, I want my row read as "Alex, you", and the load error announced, so that I hear the same information.
11. As a Member using Dynamic Type or dark mode, I want the section to scale and use the palette like the rest of Settings.

## Implementation Decisions

- **Glossary**: Display name is a glossary term: what a Member is called in their Household, set by hand.
- **Domain**: `Member` has the Account ID and the Display name, trimmed of spaces and newlines at both ends as the Household alias is. `HouseholdStore` gains `loadMembers()`, returning the Household's Members in Display-name order. The schema already has `household_members.display_name` (required, never blank) and lets Members read every membership in their Household: no schema change.
- **Data**: `SupabaseHouseholdStore.loadMembers()` reads `user_id, display_name` from `household_members` ordered by `display_name`, as the reference's `loadHouseholdMembers`.
- **State**: a `HouseholdMembersModel` (loading, ready, failed) separate from `HouseholdModel`, so the tabs never wait for it; only the latest load decides. It's made once per sign-in alongside the Household and loads the first time Settings appears; Retry is the only reload. The reference loads when its Settings screen first mounts, which is the same once-per-sign-in behavior.
- **Settings**: a native `Form` section titled "Members" below Household and above Account. Ready: one row per Member; the row whose Account ID is the signed-in Account's shows "(you)" in secondary text. Loading: one "Loading…" row in secondary text. Failed: "Could not load the members." in coral with a borderless "Retry" at the row's trailing edge, announced to VoiceOver as the reference's alert role is. No empty state: access rules always return the signed-in Member.
- **Copy**: verbatim from the reference: "Members", "Loading…", "Could not load the members.", "Retry", "(you)".
- **Layout**: the reference puts Members as a row inside the Household card; iOS gives them their own section with a row each, the native pattern for a list in a `Form`.

## Testing Decisions

- Tests check what a person sees or what a store returns, never how a view is built.
- **Household store** (recorded-server tests in `KiwiDataTests`): rows map to Members, Display names are trimmed, the query reads `household_members` selecting `user_id,display_name` ordered by `display_name`, and failures throw `couldNotLoad`.
- **Members model** (`KiwiFeaturesTests`): loading then ready; failed, then Retry, then ready; loading only once per model; an earlier load finishing last is ignored.
- **Members section**: `#Preview`s for ready, loading and failed, light and dark, and the simulator check.

## Out of Scope

- Editing Display names or Household membership in the app.
- Refreshing the Members without Retry or a new sign-in.
- The Appearance setting (KIW-41).

## Further Notes

- Parity is compared per section, against the reference's `HouseholdSection` and its tests, with the separate Members section as the layout difference.
- Validate on the local stack signed in as a seeded Account, then on the shared project with `make run-shared` for the developer's check.
