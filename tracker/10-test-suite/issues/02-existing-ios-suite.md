# Bring the existing iOS suite in line

Status: ready-for-agent
Blocked by: 01

Apply the rules from ticket 01 to all 91 existing tests in KiwiKit (see the spec's "Existing tests" and "Stub server" decisions). No production behaviour changes.

- Every test is kept, renamed, merged into another or deleted. Suites built from several units are split by unit.
- `TodayScreenTests`, `PetsScreenTests` and `NoHouseholdScreenTests` are replaced by suites named after the units they test, or deleted where they only restate the code. The known cases are:
  - the two header-title tests and `startsReadyToSignOut` are deleted;
  - the no-household message keeps only its missing-email branch, in the suite of the unit that owns it;
  - Check again and Sign out are dropped where `HouseholdModelTests` and `SignOutModelTests` already cover them;
  - `validatesAndSubmitsPetDetailsFormValues` is checked for overlap;
  - `pointsDevelopersToTheSetupSteps` is checked against the rule.
- `RecordedSupabaseServer` becomes `StubSupabaseServer`, with the same interface. Its payloads stay hand-written, and `make db-types` stays the drift guard.
- Test names and comments describe behaviour and never mention the reference app.

- [ ] `make test` passes.
- [ ] Every behaviour a kept spec lists is still covered by a test.
- [ ] No suite is named after a reference file, and no test or test comment mentions the reference.
- [ ] The handover lists each deleted or merged test with its reason, so the developer can veto it.

## Comments

- 2026-11-28 (from 01): With the rename, update the `KiwiData` row of the iOS conventions' Tests table ("Recorded JSON payloads" becomes stub payloads), name `StubSupabaseServer` in port-feature's worked example, and fix the `make test ONLY=KiwiFeaturesTests/TodayScreenTests` example in the iOS conventions' Checks if that suite goes.
