# Issue tracker

Where the engineering skills (`to-tickets`, `to-spec`, `triage`, `wayfinder`) read and write work for this repo: GitHub Issues in [PatyCu/kiwi-tracker-swift](https://github.com/PatyCu/kiwi-tracker-swift/issues), through the `gh` CLI. No GitHub Projects, and no Linear: `KIW-n` names the reference feature in Linear being ported, as read-only context.

## How the work is organised

- **Roadmap**: [`docs/migration-plan.md`](../migration-plan.md): phases, one checklist line per feature, and each phase's exit check.
- **Feature**: one issue, opened when work on the feature starts, never ahead of it. The feature's line in the plan then links to it: `- [ ] Pet overview screen (KIW-26) — [#12](https://github.com/PatyCu/kiwi-tracker-swift/issues/12)`. Its body is the spec once `/to-spec` writes it.
- **Spec**: the feature issue's body. Its `## Requirements` section lists the [requirement](../../requirements/) IDs it satisfies and never restates them. Its Implementation Decisions name only the fields, columns and cases the feature uses now.
- **Ticket**: one sub-issue of the feature per piece of work, in delivery order. A feature that is one piece of work has none; its issue is its only ticket.
- **Bug**: an issue labelled `bug`, saying what goes wrong and where it was found. Before it's fixed, a comment answers "why didn't the tests catch it?". Open bugs come before the next ticket.
- **After parity**: an improvement that would change the reference app's behaviour is an issue labelled `after-parity`, left until Phase 7 is done.
- **State**: a triage label from [`triage-labels.md`](triage-labels.md) until work starts, then assigned to the developer (`--add-assignee @me`) while in progress. Decided work starts at `ready-for-agent` or `ready-for-human`.
- **Done**: closed by the commit that finishes it: its one-line message ends with `(closes #n)`, and pushing to `main` closes the issue. A feature closes with its last ticket, and its line in the plan is ticked off in that commit.

## Commands

Check the target once per session with `gh repo view --json nameWithOwner`: it must be `PatyCu/kiwi-tracker-swift`.

- **Create**: `gh issue create --title "..." --body-file <file> --label <label>`; add `--parent <n>` for a ticket and `--blocked-by <n>,<n>` when it waits on others.
- **Read**: `gh issue view <n> --json number,title,body,labels,assignees,state,comments`.
- **List**: `gh issue list --state open --json number,title,labels,assignees`, with `--label` to filter.
- **Sub-issues**: `gh issue edit <parent> --add-sub-issue <child>`.
- **Blocking**: GitHub's issue dependencies (`gh issue edit <n> --add-blocked-by <blocker>`). A ticket is unblocked when every blocker is closed: `gh api repos/PatyCu/kiwi-tracker-swift/issues/<n> --jq .issue_dependencies_summary.blocked_by` is 0.
- **Comment**: `gh issue comment <n> --body "..."`.
- **Labels**: `gh issue edit <n> --add-label "..."` / `--remove-label "..."`.
- **Close without a commit** (a `wontfix`, a duplicate): comment why, then `gh issue close <n>`.

### When a skill says "publish to the issue tracker"

Create an issue: a feature (and link it from its line in the plan), a ticket as a sub-issue of its feature, or a bug. Add a feature to the plan only for decided work that isn't there yet.

### When a skill says "fetch the relevant ticket"

Read the issue the developer names, as in **Read**.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(`/triage` reads this flag.)_

## Wayfinding

Used by `/wayfinder`. The **map** is an issue labelled `wayfinder:map`, holding Notes / Decisions-so-far / Fog; each **child** is a sub-issue of it, labelled `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Create those labels the first time they're needed.

- **Blocking**: as in **Blocking** above.
- **Frontier**: the map's open sub-issues with no open blocker and no assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: comment the answer, close the issue, then add a gist and link to the map's Decisions-so-far.
