# Contributing

How a change gets from idea to `main`. To get the app running first, see the
[README](README.md). Code follows the conventions of the part it's in
([iOS](ios/CONVENTIONS.md), [Supabase](supabase/CONVENTIONS.md)), and every
change is checked against the [architecture principles](docs/architecture.md).

## Docs

- [docs/architecture.md](docs/architecture.md): architecture principles, with
  the decisions behind them in [docs/adr/](docs/adr/).
- [GLOSSARY.md](GLOSSARY.md): the domain's terms.
- [docs/supabase.md](docs/supabase.md): the data model.
- [docs/accounts.md](docs/accounts.md): setting up Accounts, Households and
  Members.
- [docs/migration-plan.md](docs/migration-plan.md): the roadmap, with each
  feature's tickets and the bugs under [tracker/](docs/agents/issue-tracker.md).
- [AGENTS.md](AGENTS.md) and [ios/AGENTS.md](ios/AGENTS.md): what only agents
  need.

## Plan

- Until iOS parity, the tracker is `docs/migration-plan.md` and `tracker/`, as
  [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md) describes. After
  parity it's Linear's Kiwi Tracker project. Don't use GitHub Issues or GitHub
  Projects.
- Bugs come first: log one in the tracker when it's found, and fix open bugs
  before new feature work unless the developer decides otherwise. Fixing bugs
  related to the current change is part of finishing it.
- Port a capability from the Expo app with
  [port-feature](.claude/skills/port-feature/SKILL.md).
- A spec's Testing Decisions list, by unit, the behaviors its automated tests
  cover, drawn from its user stories.
- A spec's manual check lists the behaviors only a view shows (VoiceOver
  labels and traits, a control's first state, layout fit), one line per user
  story the tests can't reach.
- Before fixing a bug, its tracker file answers "why didn't the tests catch
  it?". The fix closes that cause: the spec, the suite or the manual check.
  There's no blanket rule of one regression test per bug.

## What a change includes

- Only what the app uses now: no just-in-case columns, code, rules or docs.
- Existing patterns before new ones.
- When the change touches code that mixes responsibilities, improve that
  boundary if it's safe within the change; no unrelated refactors. After a
  refactor, remove obsolete files, declarations, imports and empty directories.
- A new production dependency only with the developer's approval.
- Build warnings, console errors and runtime warnings are part of the change:
  fix them, or explain their cause and the follow-up.
- A decision that is hard to reverse or shapes the architecture (how modules,
  data or systems fit together) gets an ADR: `docs/adr/NNNN-<slug>.md`, a few
  sentences on the context, the decision and why.
- Each Markdown document has one purpose; link to another document rather than
  copying from it. Document a capability when it's done, not while it's
  planned: `docs/migration-plan.md` is the one planning document.

## Validate

1. Run the checks in the conventions of each part the change touches.
2. Validate on the local stack, never by experimenting on the shared project.
3. Apply the change's new migrations to the shared project, and have the
   developer check the change there once (the `KiwiTracker Shared` scheme).

### Change the schema

1. Create a migration file: `supabase migration new <description>`.
2. Write the SQL, following the [Supabase conventions](supabase/CONVENTIONS.md).
3. Rebuild the local database from scratch with all migrations and the seed:
   `supabase db reset`.
4. Check the change: `supabase db lint` for schema errors, and
   `supabase test db` for access rules. Update `supabase/seed.sql` if the new
   schema needs local data, and regenerate the iOS row types (`make db-types`
   in `ios/`).

### Apply to the shared project

Migrations reach the shared project before they're committed, once they pass on
the local stack. Additive ones need no confirmation; ask the developer first
for one that could lose data or break an app already on `main`, including the
Expo app (a drop, a rename, a type change). `supabase login` opens a browser to
sign in; linking then uses that login.

```bash
supabase login
supabase link --project-ref gxljpicuptmmdwxmclwk
supabase db push --remote --dry-run
supabase db push --remote
```

Without `--remote`, `db push` targets the local database. `--dry-run` lists the
migrations the push would apply. Never pass `--include-seed`: the seed is local
test data. Then check **Advisors → Security Advisor** in the dashboard for new
warnings.

## Commit

- Trunk-based: commit to `main` and push it, unless a branch is asked for.
- One commit per change, with a one-line message: `type: what changed, in plain
  words`, specific enough that the log alone says what changed. Types: `feat`,
  `fix`, `docs`, `refactor`, `test`, `chore`.
- After iOS parity, update Linear before committing whenever a change alters
  what an app shows or can do.
