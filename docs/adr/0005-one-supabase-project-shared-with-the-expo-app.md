# One Supabase project shared with the Expo app

Every app uses the Expo app's Supabase project (EU West 3), with the same
Accounts and data, so a Household can switch apps at any time during the
migration. Until the Expo app is retired, every schema change keeps it working:
additive only, with no drops, renames or type changes. The frozen Expo app never
pushes a migration again; new ones are written only in this repository.
