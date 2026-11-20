# Kiwi Tracker agent guidance

Guidance for every part of this repository. Each app folder has its own
`AGENTS.md` with its stack and checks (`ios/AGENTS.md`); read it before working
there.

## Role and ownership

- Work with staff-level engineering judgment: optimize for correctness, maintainability, and clear trade-offs, not only for completing the immediate change.
- Raise material architectural, data-integrity, security, or maintenance risks when they affect the requested work.
- Keep recommendations proportional to the product stage; this is a prototype evolving toward production, so avoid both throwaway shortcuts and unnecessary production-scale complexity.

## Project context

- Kiwi Tracker is a pet care and health tracker for households: a native iOS app (Swift, SwiftUI) here, a React web app to follow, and a shared Supabase backend. See `docs/architecture.md`.
- Never change anything outside this folder. The Expo app's own checkout (`../kiwi-tracker`) and repo stay untouched: don't write, run, install or commit there.
- The Expo app is the reference implementation. Read and run it only from `.reference/kiwi-tracker`, a git-ignored copy pinned to its frozen commit (`c6db92f`); copy anything this repo needs out of it.- Capabilities, flows, rules, copy, branding and empty, loading and error states match the reference; platform chrome uses native components. Follow `.claude/skills/port-feature/SKILL.md` to port a capability.
- The apps are online-only: each household's pets, events and photos live in Supabase.
- `docs/migration-plan.md` says which migration phase is current and what's left in it. Work within the current phase, and follow its ground rules.

## Engineering principles

- Prefer simple, explicit solutions and avoid premature abstractions.
- Follow existing project patterns before introducing new ones.
- Add only what the app uses now: no just-in-case columns, code, rules or docs.
- Keep changes scoped to the requested task; do not modify unrelated files.
- Explain significant architectural decisions and their trade-offs.
- Prefer names that communicate responsibility or domain meaning without requiring project-specific knowledge.

## Modularity and code organization

- Give each module one cohesive responsibility and a clear reason to change. This does not require one type per file.
- Keep presentation, business logic, persistence, and external integrations separate. UI does not contain storage or API details.
- Treat screens as composition roots: they assemble components, coordinate screen-level UI state, and delegate business rules and integrations.
- Extract logic from screens when it is a business rule, a reusable state transition, data mapping, or a side effect. Keep purely visual behavior close to the view that owns it.
- Do not split code solely to reduce file length or create abstractions before a real boundary exists.
- When touching code that mixes responsibilities, improve the relevant boundary when it can be done safely within task scope; do not start unrelated refactors.

## Workflow

- Inspect the relevant code and configuration before making changes.
- After refactors, remove obsolete files, declarations, imports, and empty directories.
- Use trunk-based development by default. When asked to commit and push without an explicit branch request, commit the scoped changes directly to `main` and push `main` upstream; create a separate branch only when explicitly requested.
- Before asking a developer to repeat setup or authentication, verify whether the failure is caused by sandbox, keychain, network, or permission restrictions in the agent's execution environment.
- For GitHub publishing, attempt the HTTPS push outside the sandbox with `GIT_TERMINAL_PROMPT=0` first so keychain prompts cannot hang it. Do not add a preflight authentication check to the successful path. Only if that push returns an authentication error, run `gh auth status` with keychain access outside the sandbox, and ask the developer to log in again only when that also fails.
- Ask for confirmation before adding a new production dependency.
- Run the checks in the app's `AGENTS.md` after changes. If a relevant check is unavailable, say so instead of claiming it passed.
- Treat build warnings, console errors and runtime warnings as part of the current task: resolve them before finishing, or explain the cause and the follow-up.
- Validate changes on the local Supabase stack, never by experimenting on the shared project. Once that passes, apply the change's new migrations to the shared project, open the app on it and hand it over with what to check. The developer checks once there, and nothing is committed or pushed until they approve. Ask first only when a migration could lose data or break an app already on `main`, including the Expo app (a drop, a rename, a type change); additive migrations need no confirmation.
- When phased delivery is requested, keep a visible checklist and, for each phase, complete implementation, automated validation, validation on the local stack, the developer's check on the shared project, and wrap-up, in that order.
- Each Markdown document has a single, cohesive purpose; link across documents rather than inlining. Document a capability when it is done, not while it is planned; `docs/migration-plan.md` is the one planning document. The README is the contributor entry point: the current state and how to work on it today.
- Until iOS parity, `docs/migration-plan.md` is the only roadmap and bug list ("the tracker"); don't use Linear, GitHub Issues or GitHub Projects. After parity, the tracker is Linear's Kiwi Tracker project: follow `.claude/skills/sync-feature-tracker/SKILL.md` and sync it before committing whenever a change alters what an app shows or can do.
- Update the schema artifact (https://claude.ai/artifact/6RcgQyFvySTzAjBnq8NFuk) before committing whenever a migration changes the Supabase schema. The migrations stay the source of truth; read the artifact with the `Artifact` tool and republish it to the same URL.
- Treat bugs as P0: log a bug in the tracker when it is found, and fix open bugs before starting new feature work unless the developer decides otherwise. Fixing bugs related to the current change is part of finishing it; log only unrelated bugs for later.
- When the developer says "wrap up", follow `.claude/skills/wrap-up/SKILL.md`. For "what's next", follow `.claude/skills/next-task-prompt/SKILL.md`.

## Data and UX

- Keep persisted health data backward-compatible or provide an explicit migration.
- Do not silently discard user-entered data when storage operations fail.
- Keep behavior consistent across iOS, web and the reference app unless a platform difference is intentional and documented in `docs/architecture.md`.
