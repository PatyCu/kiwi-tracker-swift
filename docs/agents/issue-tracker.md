# Issue tracker

Where the engineering skills (`to-tickets`, `to-spec`, `triage`, `wayfinder`) read and write work for this repo. Never use GitHub Issues or GitHub Projects.

## Until iOS parity: `docs/migration-plan.md` and `tracker/`

[`docs/migration-plan.md`](../migration-plan.md) is the roadmap: phases, one checklist line per feature, and each phase's exit check. The work on a feature, and every bug, lives as Markdown files under `tracker/` at the repo root, committed with the code.

```
tracker/
├── <feature-slug>/
│   ├── spec.md              ← only if a spec was written
│   ├── map.md               ← only for wayfinding
│   └── issues/
│       ├── 01-<slug>.md
│       └── 02-<slug>.md
└── bugs/
    └── 01-<slug>.md
```

- **Feature folder**: created when work on a feature starts, never ahead of it. The feature's line in the plan then links to it: `- [ ] Sign out from Settings (KIW-n) — [tracker](../tracker/sign-out/)`. `KIW-n` is the reference feature in Linear being ported (read-only context).
- **Ticket**: one file per piece of work, `issues/NN-<slug>.md`, numbered from `01` in delivery order, never one combined file. The title is the first heading; a `Status:` line follows it (and `Blocked by: NN, NN` when it waits on other tickets); then what to build and what done looks like. Discussion goes at the bottom under `## Comments`.
- **Status**: one of the triage roles in [`triage-labels.md`](triage-labels.md), `in-progress` once work starts, or `done`, set in the commit that finishes it (`git log` on the file finds that commit). Decided work starts at `ready-for-agent` or `ready-for-human`.
- **Bug**: `tracker/bugs/NN-<slug>.md`, numbered from `01`, with a `Status:` line, what goes wrong and where it was found. When fixed, `Status: done`. Open bugs come before the next ticket.
- **Close a feature**: when its last ticket is `done`, tick it off in the plan in the same commit.

### When a skill says "publish to the issue tracker"

Create the file under the feature's folder (creating the folder, and linking it from the feature's line in the plan, if needed), or under `tracker/bugs/` for a bug. Add a feature to the plan only for decided work that isn't there yet.

### When a skill says "fetch the relevant ticket"

Read the file at the path, or the ticket number within the feature, the developer names.

### Wayfinding

Used by `/wayfinder`. The **map** is `tracker/<effort>/map.md` (Notes / Decisions-so-far / Fog); each **child** is `tracker/<effort>/issues/NN-<slug>.md`.

- A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); `Status:` is `claimed` or `resolved` here.
- **Blocking**: `Blocked by: NN, NN`. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: open, unblocked, unclaimed files in `issues/`; lowest number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under `## Answer`, set `Status: resolved`, then add a gist and link to the map's Decisions-so-far.

## After iOS parity (Phase 7 done): Linear

The tracker is Linear's Kiwi Tracker project, kept in sync through `.claude/skills/sync-feature-tracker/SKILL.md`. Use the Linear MCP tools. Phase 7 moves the open work in `tracker/` there.

- **Publish**: `save_issue` in the Kiwi Tracker project (check `list_issues` for a duplicate first).
- **Fetch**: `get_issue`, plus `list_comments` for the discussion.
- **Triage state**: labels from `triage-labels.md`.
- **Wayfinding**: the map is a parent issue; each child ticket is a sub-issue. Blocking uses Linear's "blocked by" relations; claim by assigning to `me`; resolve with a comment, then close and add a pointer to the map's Decisions-so-far.
