# Database access tests

Status: done
Blocked by: 01

Row-level security is the only authorization layer (ADR 0003), so it gets automatic tests. This ticket covers user stories 27–36 of the spec and its "Database tests", "Supabase conventions" and "Wrap-up" decisions.

- pgTAP files, plain pgTAP with no helper extension, go in the Supabase folder's tests directory and run with `supabase test db` after `supabase db reset`.
- Each file runs in a transaction it rolls back. As the superuser it creates its own Auth users, Households, memberships and Pets, so it never depends on `seed.sql`. It then acts as:
  - a member of that Household;
  - a member of another Household;
  - a signed-out user.

  Each of these runs as the `authenticated` or `anon` role with the Account's JWT claims.
- The cases are the access rules `docs/supabase.md` states, for `households`, `household_members`, `pets`, `pet_events` and `calendar_events`, across select, insert, update and delete where the role can attempt them:
  - which rows are visible and which are hidden;
  - which writes are allowed and which are refused;
  - updating a Pet into another Household is refused;
  - creating Households and changing memberships is refused for every app role;
  - every table refuses a signed-out user.
- The Supabase conventions' Checks become `supabase db reset`, `supabase db lint`, then `supabase test db`. They say each table's access rules have pgTAP tests, that a migration changing a policy changes its tests, and they link to the testing principle.
- Wrap-up runs `supabase test db`, after a reset, for any change under `supabase/`.
- Storage (`pet-photos`) policies are out of scope (KIW-24).

- [x] `supabase db reset && supabase test db` passes on the local stack, with one case per rule, role and operation that the rule constrains.
- [x] Where the database disagrees with `docs/supabase.md`, the case is logged under `tracker/bugs/`, not bent to pass.
- [x] No migration and no schema change.

## Comments

- 2026-11-28 (from 01): Principle 14 in `docs/architecture.md` ends by linking to the iOS conventions only. Add the Supabase conventions' link there once they carry the pgTAP rules.
- 2026-11-28: 56 cases in `supabase/tests/`, one file per table. The database matched `docs/supabase.md` everywhere, so no bug was logged. A copy of the pets file with a permissive policy failed 5 of its 13 cases. Principle 14 now links to the Supabase conventions.
