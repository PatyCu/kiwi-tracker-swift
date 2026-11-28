# Requirements

What Kiwi Tracker does, in observable behaviour: one file per area, one ID per
behaviour. Specs and tests cite these IDs. The format and the rules for
writing, approving and dropping requirements are in the
[requirements skill](../../.claude/skills/requirements/SKILL.md). The
[req-coverage skill](../../.claude/skills/req-coverage/SKILL.md) checks which
`active` requirements have tests.

A `Source:` path is relative to the reference copy `.reference/kiwi-tracker`,
unless it starts with `ios/` or `supabase/`. `decision` means the developer
decided it.

| Prefix | Area | File |
|---|---|---|
| AUTH | Signing in, Sessions and signing out | [auth.md](auth.md) |
| HH | Households and Members | [households.md](households.md) |
| SET | Settings and Appearance | [settings.md](settings.md) |
| PET | Pets and their details | [pets.md](pets.md) |
| PHOTO | Pet photos | [pet-photos.md](pet-photos.md) |
| EVT | Pet events, the current diet and the timeline | [pet-events.md](pet-events.md) |
| STAT | Pet status | [pet-status.md](pet-status.md) |
| TODAY | The Today tab | [today.md](today.md) |
| CAL | Calendar and Calendar events | [calendar.md](calendar.md) |
| APP | The app shell: tabs, routing, app-wide states | [app-shell.md](app-shell.md) |
