# Data model

What the Supabase backend stores and who can reach it. The migrations in
`supabase/migrations/` are the source of truth; the rules they follow are in
[supabase/CONVENTIONS.md](../supabase/CONVENTIONS.md).

| Table / bucket      | Holds                                                                                                                  |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `households`        | Households, each with an `alias` the app shows.                                                                        |
| `household_members` | Which household each Supabase Auth user belongs to (one each), and the `display_name` they go by in it.                |
| `pets`              | Pets, each in one household (`household_id`).                                                                          |
| `pet_events`        | Symptoms, diet changes and other events for a pet: `occurred_at` is when it happened, `created_at` when it was logged. |
| `calendar_events`   | Planned care for a pet, such as a vet visit, with a start and end time on one day.                                     |
| `pet-photos`        | Private storage bucket, files under `<pet_id>/<file>`.                                                                 |

Every member of a household can read, add, edit and delete its pets, and those
pets' events and photos, and can read and add those pets' calendar events. A
pet can't be moved to a household the user isn't in.
People outside the household see none of it, and signed-out users have no
access. Members can read their household and everyone's membership in it, but
only the dashboard can create households or change memberships.

Each pet has at most one photo, stored under its own name,
`<pet_id>/<timestamp>.jpg`, with that path in `pets.photo_path`; a new photo
replaces the file. The bucket is private: iOS downloads photos by path through
the signed-in session, and the Expo app shows them through signed links, which
anyone holding one can open until it expires, so removing someone from a
household cuts off its photos there only when their links expire. Either app
keeps a photo it has shown on the device, so a removed member keeps those
copies until they sign out.
