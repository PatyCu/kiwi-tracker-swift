---
name: requirements
description: Author, update, extract or drop app requirements in docs/requirements/*.md, the repo's permanent source of truth for app behaviour. Use when a behaviour is decided, changed or dropped, when extracting behaviour from the legacy Expo app, or when a spec or test needs a requirement ID.
---

# Requirements

`docs/requirements/` states **what** Kiwi Tracker does, in observable behaviour. It is permanent and outlives every spec and ticket.

- Specs (from `/to-spec`) say **how** a change gets there, and they **reference** requirement IDs. They never restate them.
- Tests prove requirements. Each test carries the IDs it proves (see `req-coverage`).
- Terms come from `GLOSSARY.md`. Decisions with a "why" go in ADRs, not here.

## Layout

```
docs/requirements/
  README.md        # prefix registry + format reminder (create if missing)
  meds.md          # one file per area, named after the area
  reminders.md
  ...
```

`README.md` holds the prefix registry:

```markdown
| Prefix | Area | File |
|---|---|---|
| MED | Medication and regimes | meds.md |
```

## Requirement format (exact; `req-coverage` parses it)

```markdown
### MED-004: Multi-step regime advances to the next step
Status: active
Migration: changed
Source: src/modules/meds/ui/RegimeScreen.tsx

When the last dose of a regime step is logged, the next step's reminders start the following day.
```

The body is **one declarative sentence** (two at most). Scenarios, data and assertions live in the tests, not here. Reason: if both the requirement and the test spell out Given/When/Then, the same behaviour exists twice and the copies drift. `req-coverage` can only check that an ID is referenced, not that the texts still agree.

| Field | Values | Rule |
|---|---|---|
| ID | `PREFIX-NNN` (2-6 uppercase letters, 3 digits) | Next free number in that prefix. **Never reuse or renumber.** |
| Title | One line | Describes the behaviour, not the UI element |
| Status | `draft` / `active` / `dropped` | Only `active` must be covered by tests |
| Migration | `same` / `changed` / `new` | Optional. Relation to the Expo behaviour. Remove after cutover if you like |
| Source | Path or `decision` | Where the behaviour came from; paths as `docs/requirements/README.md` says |
| Note | One line | Optional. A confirmed difference from the reference, or `possible bug, confirm` |

## Rules

1. **Observable behaviour only.** No Swift types, no screens' internals, no storage choices. Test: could QA verify it without reading code? If not, rewrite it or move it to an ADR.
2. **One behaviour per ID.** An "and" joining two outcomes means split it. An edge case worth testing (empty state, offline, timezone change) gets its own ID.
2b. **No UX quality requirements.** "Easy", "fast to log", "clear", "delightful" are not testable here. Route them to `/prototype` and design review. Only the observable rule underneath (e.g. "logging a dose takes one tap from the reminder") qualifies.
3. **Agents create `draft` only.** Only the human moves a requirement to `active` or `dropped`, in a grilling session. Never self-approve.
4. **Dropping keeps history.** Set `Status: dropped` and add `Reason:` with one line. Never delete the block.
5. **Changing behaviour** of an `active` requirement: edit it in place only if tests are updated in the same change. Otherwise flag it.
6. **Use GLOSSARY terms.** A new term goes through `domain-modeling` first.
7. **No duplicates.** Before adding, search `docs/requirements/` for the behaviour. Extend or reference instead.

## Workflows

### Extract from Expo (research tickets, can run AFK)
1. Read one area of the Expo app (screens, state, notifications, storage, backend calls, edge cases in code).
2. Write each behaviour as `Status: draft`, `Migration: same`, with `Source:` pointing at the file.
3. Include edge cases the code handles (empty states, errors, timezones, offline), each as its own ID. These are the ones migrations lose.
4. Mark suspected bugs with `Note: possible bug, confirm`. Do not encode them as intended behaviour.
5. Stop. Do not activate. Hand back the list of new IDs.

### Approve (HITL, inside `/grill-with-docs` or `/grill-me`)
1. Show all drafts of one area as a table: `ID | Title | Behaviour | Suggested: keep/change/drop`.
2. The user marks each row. `keep` becomes `active`, `drop` becomes `dropped` with a `Reason:`.
3. Grill only the `change` rows and any `possible bug` notes, one at a time, then set `Migration: changed`.

Reason: one question per draft is slow and expensive across 100+ drafts. Most rows are simple confirmations, so only the contested ones get a grilling.

### New behaviour
Allocate the next ID, write it as `draft`, get the user's approval, then `active`.

## Interop with other skills

- `/to-spec`: the spec must contain a `## Requirements` section listing the IDs it satisfies. No behaviour may appear in a spec without an ID.
- `/to-tickets`: each ticket lists the IDs it covers.
- `/tdd`, `/implement`: write tests that name the ID. Run `req-coverage` before finishing.
- `/code-review`: the Spec axis checks the diff against the listed requirements.

## After the Expo cutover

When no `active` requirement is uncovered and no `draft` is left, tell the user a review is due:
- Remove the `Migration:` fields, since they no longer carry information.
- Check for redundancy: if requirement sentences only restate test names, propose collapsing `docs/requirements/` into the tests (or generating the doc from test names). That decision belongs to the user.

## Never

- Activate, drop or renumber requirements without the user.
- Put implementation detail, scenarios or test data here.
- Commit specs or tickets to the repo. They live on the tracker.
- Write requirements for behaviour nobody confirmed.
