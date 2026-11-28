# Households and Members

### HH-001: The tabs open once the Household has loaded
Status: draft
Migration: same
Source: src/app/_layout.tsx

After sign-in the app shows loading until the Account's Household has loaded, and only then opens the tabs.

### HH-002: A failed Household load offers Retry
Status: draft
Migration: same
Source: src/app/_layout.tsx

When the Household can't be loaded, the app shows the load error with Retry, and shows loading again while Retry runs.

### HH-003: An Account without a Household sees the no-household screen
Status: draft
Migration: same
Source: src/modules/households/ui/NoHouseholdScreen.tsx

A signed-in Account in no Household sees "This account isn't in a household yet" and "‹email› needs to be added to a household before you can use Kiwi Tracker. Ask whoever set up your account, then check again."

### HH-004: A missing Household is told apart from a failed load
Status: draft
Migration: same
Source: src/modules/households/state/HouseholdProvider.tsx

A load that fails shows the error with Retry, never the no-household screen.

### HH-005: Check again picks up a new membership
Status: draft
Migration: same
Source: src/modules/households/ui/NoHouseholdScreen.tsx

"Check again" shows loading, then opens the app if the Account was added to a Household since the last check.

### HH-006: The no-household screen offers Sign out
Status: draft
Migration: same
Source: src/modules/households/ui/NoHouseholdScreen.tsx

The no-household screen has a "Sign out" button that signs out as Settings does.

### HH-007: Only the latest Household load counts
Status: draft
Migration: same
Source: src/modules/households/state/HouseholdProvider.tsx

When loads overlap, an earlier load that finishes last doesn't replace the result of a later one.

### HH-008: Each sign-in sees only its own Household
Status: draft
Migration: same
Source: src/modules/households/state/HouseholdProvider.tsx

After signing in as another Account, the app shows only that Account's Household, never the previous one's.

### HH-009: Today's title names the Household
Status: draft
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

Today's title reads "Today in ‹alias›".

### HH-010: Pets' title names the Household
Status: draft
Migration: same
Source: src/modules/pets/ui/PetsScreen.tsx

Pets' title reads "Pets in ‹alias›".

### HH-011: Settings shows the Household alias
Status: draft
Migration: changed
Source: src/modules/households/ui/HouseholdSection.tsx

Settings' Household section shows the Household alias in a row labelled "Alias", where the reference says "Name".

### HH-012: The alias is shown trimmed
Status: draft
Migration: same
Source: src/modules/households/model/Household.ts

The Household alias is shown without spaces or newlines at either end.

### HH-013: Settings lists the Household's Members by Display name
Status: draft
Migration: same
Source: src/modules/households/ui/HouseholdSection.tsx

Settings lists every Member of the Household by Display name, never by email, sorted by Display name.

### HH-014: The signed-in Member is marked "(you)"
Status: draft
Migration: same
Source: src/modules/households/ui/HouseholdSection.tsx

In the Members list, only the signed-in Member's row ends with "(you)".

### HH-015: Display names are shown trimmed
Status: draft
Migration: same
Source: src/modules/households/model/HouseholdMember.ts

A Display name is shown without spaces or newlines at either end.

### HH-016: Members show loading while they load
Status: draft
Migration: same
Source: src/modules/households/ui/HouseholdSection.tsx

The Members list shows "Loading…" until the Members have loaded.

### HH-017: A failed Members load offers Retry
Status: draft
Migration: same
Source: src/modules/households/ui/HouseholdSection.tsx

When the Members can't be loaded, Settings shows "Could not load the members." with "Retry", and the rest of the app keeps working.

### HH-018: Members load once per sign-in
Status: draft
Migration: same
Source: src/modules/households/state/useHouseholdMembers.ts

The Members load the first time Settings opens after sign-in, and only Retry loads them again.

### HH-019: A Member sees only their own Household
Status: draft
Migration: same
Source: supabase/migrations

A Member can read their own Household and its memberships, and nothing of any other Household.

### HH-020: Households and memberships can't be changed from the app
Status: draft
Migration: same
Source: supabase/migrations

No Account can create, edit or delete a Household or a membership; they are set up by hand.

### HH-021: Signed-out people can't read Households
Status: draft
Migration: same
Source: supabase/migrations

A signed-out person can't read or change any Household or membership.

### HH-022: The load error says nothing was changed
Status: draft
Migration: same
Source: src/shared/ui/LoadState.tsx

The load error reads "Could not load your data", "Check your connection and try again." and "Your saved data has not been changed."

### HH-023: The Household's Retry also retries what failed with it
Status: draft
Migration: same
Source: src/app/_layout.tsx

Retry on the Household load error also reloads the Pets, Pet events and Calendar events that failed to load, so one Retry opens the app.
