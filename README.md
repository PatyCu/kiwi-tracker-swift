# Kiwi Tracker (native)

Pet care and health tracker for households. This repo holds the native iOS app
(SwiftUI) and the Supabase backend. The Expo app,
[PatyCu/kiwi-tracker](https://github.com/PatyCu/kiwi-tracker), is the
reference it matches.

Status: [Phase 2 — Accounts and households](docs/migration-plan.md).

## Prerequisites

1. Install Xcode 27 with an iOS 26 simulator.
2. Install Colima (Docker runtime) and the Supabase CLI:

   ```bash
   brew install colima docker supabase
   ```

## Run

1. Start the backend from the repo root. It applies the migrations and seed.

   ```bash
   colima start --cpu 4 --memory 6
   ```

   ```bash
   supabase start
   ```

2. Open the project, pick the `KiwiTracker` scheme and an iPhone simulator,
   and press Run (⌘R).

   ```bash
   open ios/KiwiTracker.xcodeproj
   ```

3. Sign in as `alex@kiwi.test` with password `kiwi-local-dev`. Other seeded
   accounts are listed in [supabase/seed.sql](supabase/seed.sql).

Stop with `supabase stop`, then `colima stop`. Stop the Expo repo's stack
first if it's running: both use the same containers and ports.

## Checks

From `ios/`: `make format-check`, `make build`, `make test`.

## Docs

- [docs/architecture.md](docs/architecture.md): system and iOS design,
  environments (including the `KiwiTracker Shared` scheme).
- [docs/supabase.md](docs/supabase.md): data model, local stack, schema
  changes.
- [docs/migration-plan.md](docs/migration-plan.md): roadmap; tickets and bugs
  are under [tracker/](docs/agents/issue-tracker.md).
- [AGENTS.md](AGENTS.md) and [ios/AGENTS.md](ios/AGENTS.md): engineering rules
  and workflow.
