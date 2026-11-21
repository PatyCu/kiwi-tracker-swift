# Kiwi Tracker (native)

A pet care and health tracker for households: log symptoms, diet changes and
other events per pet, plan care in a calendar, and see an at-a-glance health
status across all pets.

This repository holds the native iOS app (Swift, SwiftUI) and, as their work
starts, the React web app and the Supabase backend. The Expo app,
[PatyCu/kiwi-tracker](https://github.com/PatyCu/kiwi-tracker), is the
reference they match.

> Status: Phase 1 (Foundation). The Supabase backend and the Xcode project
> live here; the app shows no screens yet.

## Docs

- [docs/architecture.md](docs/architecture.md) — system design, iOS
  architecture, environments and testing.
- [docs/supabase.md](docs/supabase.md) — data model, accounts, local stack
  and schema changes.
- [docs/migration-plan.md](docs/migration-plan.md) — migration phases and
  where we are.
- [AGENTS.md](AGENTS.md) and [ios/AGENTS.md](ios/AGENTS.md) — engineering
  principles, workflow and checks, for people and agents.

## Prerequisites

- Xcode 27 with an iOS 26 simulator.
- The Supabase CLI and a Docker-compatible runtime (Colima); see
  [docs/supabase.md](docs/supabase.md#local-development).
- The reference app's pinned copy at `.reference/kiwi-tracker` (see
  [Phase 0](docs/migration-plan.md#phase-0--decisions-and-setup)).

## Contributing

- Trunk-based development: scoped changes go to `main` unless a branch is
  requested.
- Bugs are P0 — fix open bugs before new feature work.
- Until iOS parity, the roadmap lives in
  [docs/migration-plan.md](docs/migration-plan.md), and each feature's tickets
  and the known bugs in [tracker/](docs/agents/issue-tracker.md); after it, in
  Linear's Kiwi Tracker project. Never in GitHub Issues or Projects.
