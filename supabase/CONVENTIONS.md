# Supabase conventions

The rules the schema and its migrations follow. What the schema holds:
[docs/supabase.md](../docs/supabase.md). How a schema change is validated and
applied: [CONTRIBUTING.md](../CONTRIBUTING.md#change-the-schema).

- Name each migration `<YYYYMMDDHHMMSS>_<description>.sql` (create it with
  `supabase migration new`). Never edit a migration that has already been
  applied; add a new one instead.
- Every table has a `uuid` `id`, which the database generates when the insert
  leaves it out.
- Every table has row-level security enabled, with access limited to the
  signed-in Account's Household: `private.is_household_member()` on `pets`,
  `private.accessible_pet_ids()` for events, calendar events and photos.
  Changing who can reach a pet changes that function, not the stored rows or
  photo paths.
- Public sign-up stays off (`enable_signup = false` in `config.toml`).
- Each table's access rules, as [docs/supabase.md](../docs/supabase.md) states
  them, have pgTAP tests in `tests/`, one case per rule, role and operation
  (the [testing principle](../docs/architecture.md)). A migration that changes
  a policy or grant changes its tests in the same change. Each test file runs
  in a transaction it rolls back, creates its own Accounts, Households and
  Pets instead of relying on `seed.sql`, and acts as the `authenticated` or
  `anon` role, with an Account's JWT claims when signed in. Plain pgTAP, no helper extension.

## Checks

From the repo root: `supabase db reset`, `supabase db lint`, then
`supabase test db`. After a schema change, regenerate the iOS row types with
`make db-types` in `ios/`.
