# No API server: row-level security is the authorization layer

Clients call Supabase Auth, PostgREST and Storage directly. Postgres row-level
security decides who sees what, through `private.is_household_member()` and
`private.accessible_pet_ids()`. The Expo app already works this way, and the
new clients join its backend unchanged ([ADR 0005](0005-one-supabase-project-shared-with-the-expo-app.md));
an API server would be one more service to build, run and secure. The cost is
that rules needing the device's time can't run on the backend
([ADR 0006](0006-domain-rules-run-on-each-client.md)).
