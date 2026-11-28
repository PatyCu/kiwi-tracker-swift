---
name: req-coverage
description: Check which active requirements in docs/requirements/*.md lack Swift or pgTAP tests, and flag broken IDs, orphan test IDs and tests for dropped requirements. Use before finishing any implementation, when asked for migration status or parity gaps, or when tests or requirements change.
---

# Requirement coverage

A requirement is **covered** when at least one Swift test file references its ID. The uncovered `active` requirements are the remaining migration backlog.

## Run

```bash
.claude/skills/req-coverage/scripts/req-coverage.sh          # integrity check (CI default)
.claude/skills/req-coverage/scripts/req-coverage.sh strict   # also fail on uncovered (parity gate)
.claude/skills/req-coverage/scripts/req-coverage.sh report   # never fails, just prints
```

Env overrides: `REQ_DIR` (default `docs/requirements`), `TEST_ROOT` (default `.`). Test files are `*.swift` under any path containing `Tests`, and the pgTAP tests in `supabase/tests/*.sql`, excluding `.build`, `DerivedData` and `.reference`. Only IDs whose prefix is in `docs/requirements/README.md` count.

## How tests reference IDs

Any of these works (underscore form is normalised to hyphen):

```swift
@Test("MED-004 step B reminders start the day after step A ends")   // Swift Testing
func test_MED_004_stepBStartsAfterStepA() { ... }                     // XCTest
// Covers: MED-004, MED-005                                           // comment above a test
```

In a pgTAP file, a `-- Covers: …` line under its header comment.

Reference an ID only in a test that actually asserts that behaviour. A mention without an assertion is false coverage.

## Reading the output

| Section | Meaning | Action |
|---|---|---|
| UNCOVERED | `active` with no test | Backlog. Fail only in `strict` |
| ORPHAN | Test cites an ID that does not exist | Fix the test or create the requirement (as `draft`) |
| DROPPED BUT TESTED | Tests for `dropped` behaviour | Delete or retarget those tests |
| DUPLICATE ID / BAD ID / BAD STATUS | Requirements file is malformed | Fix the requirement block |

## Agent rules

1. Run it at the end of every `/implement` or `/tdd` session. Report the line `Coverage: X/Y`.
2. Never "fix" UNCOVERED by adding an ID to a test that does not assert the behaviour.
3. Never edit requirement statuses to make the check pass. That is the user's call (see `requirements`).
3b. **Drift check (the script can't do it):** when you change a test that cites an ID, or change a requirement, reread the other side and confirm they still agree. If they don't, stop and ask which one is right. Never silently edit the requirement to match the code.
4. When asked "how far is the migration?", run `report` and summarise UNCOVERED grouped by prefix.
