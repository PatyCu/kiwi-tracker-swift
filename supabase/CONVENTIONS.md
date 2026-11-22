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

## Checks

From the repo root: `supabase db reset`, then `supabase db lint`. After a schema
change, regenerate the iOS row types with `make db-types` in `ios/`.
