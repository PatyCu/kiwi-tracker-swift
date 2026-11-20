---
name: sync-feature-tracker
description: Sync the Kiwi Tracker roadmap and bug list in Linear (features by phase, their tasks, and bugs) with the current code. Only after iOS parity (docs/migration-plan.md Phase 7); before that the migration plan is the tracker. Use when AGENTS.md calls for a Linear sync, or when asked to "sync the feature tracker".
---

# Sync the feature tracker

Not used until iOS parity: until then `docs/migration-plan.md` is the tracker, and this skill does nothing. After parity, Linear is the only roadmap and bug list. GitHub Issues and GitHub Projects are not used.

- Workspace **PatyCu Projects**, team **Kiwi Tracker** (key `KIW`), project **Kiwi Tracker** (the same project the Expo app used): https://linear.app/patycu-projects/project/kiwi-tracker-76056a1b09ae
- Read and write it with the Linear connector tools (`list_issues`, `get_issue`, `save_issue`). Pass `team: "Kiwi Tracker"` and `project: "Kiwi Tracker"` on every new issue.

## How the tracker is organized

Every feature, task and bug is an issue in the Kiwi Tracker project.

- **Feature**: a top-level issue with the `Feature` label and one `Area` label.
  - Title: the feature's name, as in the reference project. Description: one or two sentences on what it is, not the work plan.
  - Tasks: a feature that needs more than one piece of work gets one sub-issue per task, in delivery order, with the same milestone and priority as the feature. Sub-issues get no labels.
- **Bug**: an issue with the `Bug` label, priority Urgent and no milestone. The description says what happens and, once fixed, `Fixed in <short commit hash>.`
- **Phase**: the issue's milestone. The developer sets the phase order by ordering the project's milestones in Linear; read it with `list_milestones` (lowest `sortOrder` first) and never assume a fixed order. A feature with no milestone is Unplanned.
- **Area**: a label in the `Area` group. Add a new area label only when no existing one fits.
- **Priority**: P0 is High, P1 is Medium, P2 is Low. Unplanned rows have no priority until the developer sets one. Urgent is only for bugs.
- **Status**:
  - Done: finished and matching the reference.
  - In Progress: work has started and isn't finished.
  - Todo: ready for development; a placeholder or a partial version is already in the app.
  - Backlog: nothing in the app yet.
  - Canceled: deliberately dropped.
- **Last sync**: the project description's `Last synced at commit <hash>.` line.

## Who owns which fields

- **From the code** (the sync updates these): status of features, tasks and bugs; feature descriptions; a bug's `Fixed in` line.
- **Set by the developer** (never changed by the sync unless the developer asks): milestone and priority.

## Steps

1. Read the project's issues with `list_issues` (`project: "Kiwi Tracker"`, `limit: 250`, follow `cursor` while `hasNextPage`), and the last-synced commit from the project description (`get_project`).
2. Work out what the code supports now. Look at:
   - The iOS app's routes (`Route`) and screens in `ios/KiwiKit/Sources/KiwiFeatures/*/UI`
   - Domain models and rules in `ios/KiwiKit/Sources/KiwiDomain`, and the operations the models in `KiwiFeatures/*/State` expose
   - Remaining placeholders and "Coming soon" text
   - `git log` since the last-synced commit
3. Compare the code with the issues:
   - A feature that changed state gets a new status, its finished tasks set to Done, and its description updated if needed.
   - A new capability that matches no issue gets a new feature with no milestone and no priority. Ask the developer which phase and priority it belongs to.
   - Never cancel an issue just because you didn't find its code. Cancel it only when the feature was deliberately dropped, and say so.
   - A bug fixed in this work gets status Done and its `Fixed in` line.
4. Make each change with `save_issue`, passing only the fields that change. Then set the project description's `Last synced at commit` line to `git rev-parse --short HEAD` with `save_project` (`patch`).
5. Tell the developer in a short list what changed (issues added, status changes, issues canceled, bugs fixed) with their `KIW-` identifiers and the project link.

## Picking the next item

Open bugs come first. After that, the next item is the first unfinished feature in the earliest milestone in Linear's milestone order, sorted by:

1. Priority (High, then Medium, then Low)
2. Status: In Progress, then Todo, then Backlog
3. Issue number (lowest first)

Don't suggest Unplanned features unless the developer asks. When the developer names a different item, do that one.

## Starting work on a feature

When you start building a feature, set it to In Progress. When the work is finished, the sync sets it to Done, or to Todo if only part of it landed.

## Logging a bug

When a bug is found, create it right away: `Bug` label, priority Urgent, status Todo, title saying what goes wrong, description with what happens and where it was found. If the fix lands in the same change, create it as Done with its `Fixed in` line. The developer also logs bugs and new items directly in Linear; treat those like any other issue.

## When the tracker can't be updated

If this environment has no Linear connector, or a write fails, don't block the work. Tell the developer that the tracker is out of date and which issues should change.
