# Online-only clients

Each Household's pets, events and photos live in Supabase. A device keeps only
its Session and a cache of pet photos: no offline writes and no sync engine.
The Expo app works this way, and every app shares its data
([ADR 0005](0005-one-supabase-project-shared-with-the-expo-app.md)), so offline
writes would need conflict handling across apps. The cost is that an app shows
and changes nothing without a connection.
