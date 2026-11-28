# Kiwi Tracker agent guidance

What only agents need. Everything a contributor follows applies to agents too:
[CONTRIBUTING.md](CONTRIBUTING.md), the [architecture principles](docs/architecture.md)
and their [ADRs](docs/adr/), the [GLOSSARY.md](GLOSSARY.md) terms, and the
conventions of the part being changed ([iOS](ios/CONVENTIONS.md),
[Supabase](supabase/CONVENTIONS.md)). Each app folder has its own `AGENTS.md`
(`ios/AGENTS.md`); read it before working there.

## Role

- Work with staff-level engineering judgment: optimize for correctness, maintainability, and clear trade-offs, not only for completing the immediate change.
- Raise material architectural, data-integrity, security, or maintenance risks when they affect the requested work, and explain significant decisions and their trade-offs.
- Keep recommendations proportional to the product stage; this is a prototype evolving toward production, so avoid both throwaway shortcuts and unnecessary production-scale complexity.

## The Expo app

- Never change anything outside this folder. The Expo app's own checkout (`../kiwi-tracker`) and repo stay untouched: don't write, run, install or commit there.
- Read and run the Expo app only from `.reference/kiwi-tracker`, a git-ignored copy pinned to its frozen commit (`c6db92f`); copy anything this repo needs out of it. Follow `.claude/skills/port-feature/SKILL.md` to port a capability.
- `docs/migration-plan.md` says which migration phase is current and what's left in it. Work within the current phase, and follow its ground rules.

## Workflow

- Run the checks yourself. If a relevant check is unavailable, say so instead of claiming it passed.
- Before asking a developer to repeat setup or authentication, verify whether the failure is caused by sandbox, keychain, network, or permission restrictions in the agent's execution environment.
- For GitHub publishing, attempt the HTTPS push outside the sandbox with `GIT_TERMINAL_PROMPT=0` first so keychain prompts cannot hang it. Do not add a preflight authentication check to the successful path. Only if that push returns an authentication error, run `gh auth status` with keychain access outside the sandbox, and ask the developer to log in again only when that also fails.
- Apply the change's new migrations to the shared project yourself, open the app on it, and hand it over to the developer with what to check.
- When phased delivery is requested, keep a visible checklist and, for each phase, complete implementation, automated validation, validation on the local stack, the developer's check on the shared project, and wrap-up, in that order.
- Update the schema artifact (https://claude.ai/artifact/6RcgQyFvySTzAjBnq8NFuk) before committing whenever a migration changes the Supabase schema. The migrations stay the source of truth; read the artifact with the `Artifact` tool and republish it to the same URL.
- A feature goes `/grill-with-docs`, `/to-spec`, then `/implement`, each run by the developer. Running `/implement` approves the spec, so code starts only then; until then the work ends at the written spec.
- When the developer says "wrap up", follow `.claude/skills/wrap-up/SKILL.md`. For "what's next", follow `.claude/skills/next-task-prompt/SKILL.md`.

## Agent skills

### Issue tracker

`docs/migration-plan.md` is the roadmap; features, their tickets and bugs are GitHub issues in this repo. Read `docs/agents/issue-tracker.md` before opening, labelling or closing an issue, or changing a checkbox in the plan.

### Triage labels

The five default labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), as GitHub labels, plus `bug` and `after-parity`. See `docs/agents/triage-labels.md`.

### Requirements

`docs/requirements/*.md` states what the app does, one ID per behaviour; specs and tests cite the IDs. Follow `.claude/skills/requirements/SKILL.md` to write them and `.claude/skills/req-coverage/SKILL.md` to check their tests.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Prototypes

A prototype only helps the developer decide. Once they have, delete it and its branch, and leave it out of specs, ADRs and the tracker unless they ask; this replaces the prototype skill's capture step.
