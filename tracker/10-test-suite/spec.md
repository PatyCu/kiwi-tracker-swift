# A test suite that protects what the specs promise

Status: ready-for-agent

## Problem Statement

The developer is building the base of a production app with real users, and needs its tests to catch regressions and prove that each feature does what its spec says. Today's suite was shaped by the migration instead:

- Tests are ported "case for case" from the Expo app's Jest tests, and suites are named after the reference's files. So `TodayScreenTests` tests a title function, and `NoHouseholdScreenTests` repeats cases that belong to `HouseholdModel` and `SignOutModel`.
- Code, tests and their comments describe units "as the reference app's X", which ties the new architecture to an app that will be retired.
- Some tests only restate the code: a literal string, the default values of properties.
- The row-level security rules are the only authorization layer (ADR 0003), yet nothing tests them automatically. The only check is the developer trying the seeded Accounts by hand.
- None of the four bugs fixed so far was caught by the suite. Two were requirements no spec wrote down (a reinstall staying signed in, `kiwitracker://` URL handling nobody used). Two were behaviours only a view shows (VoiceOver on the pet card, the date of birth calendar). No process asks why a bug got through.

## Solution

Every test exists because a spec promises a behaviour, and checks that behaviour the way its caller sees it. Suites are named after the Swift unit they test. Code and tests never mention the reference app; it only feeds the specs. Tests that restate the code, or repeat a behaviour already tested at a lower layer, are deleted. pgTAP tests on the local stack check who can read and write each table. Each spec's manual check lists the behaviours only a view shows. A bug fix starts by answering why the suite missed it, and closes that cause.

## User Stories

1. As the developer, I want every test to trace to a behaviour a spec promises, so that the suite protects what the app is meant to do rather than how the old app was built.
2. As the developer, I want no test that exists only to prove the migration matched the reference, so that nothing needs cleaning up when the reference is retired.
3. As the developer, I want tests to drive a unit through its public interface and check what its caller sees, so that a refactor that keeps the behaviour keeps every test green.
4. As the developer, I want what crosses a boundary (what reaches a store, auth or the server) to count as behaviour, so that writes and "nothing was sent" cases are tested.
5. As the developer, I want no mock of anything inside the unit under test, so that tests don't pin down how it's built.
6. As the developer, I want a test to stay only if a plausible wrong change that still compiles would make it fail, so that every test that runs earns its compute time.
7. As the developer, I want no tests that assert constants, default values or plain pass-throughs, so that the suite carries no noise.
8. As the developer, I want no test that asserts a string copied from the code, so that changing copy on purpose doesn't mean editing a test too.
9. As the developer, I want copy built by logic (a branch, a formatted list) tested for its logic, so that the branch is protected without restating the sentence.
10. As the developer, I want each behaviour tested once, at the lowest layer that can show it, so that one change doesn't mean editing several tests.
11. As the developer, I want a form's tests to check that it blocks Save when its details are invalid, not every invalid case again, so that validation cases live only in the domain tests.
12. As the developer, I want each suite named after the Swift unit it tests, so that I find a unit's tests by its name.
13. As the developer, I want each test named after the behaviour it checks, in words, so that a failing test says which promise broke.
14. As the developer, I want code, tests and their comments never to mention the reference app, so that the new architecture is independent of the legacy one.
15. As the developer, I want each doc comment that says "as the reference app's X" rewritten to say what the unit does, so that the comment still explains it after the reference is gone.
16. As the developer, I want specs, the tracker and the migration plan to be the only places that mention the reference, so that tracing parity stays possible without leaking into the code.
17. As an agent porting a feature, I want `port-feature` to tell me to read the reference and its tests to find behaviours for the spec, then write the tests from the spec, so that I don't port Jest cases one for one.
18. As the developer, I want each spec's Testing Decisions to list, by unit, the behaviours its automated tests cover, drawn from its user stories, so that I can see what the tests promise before code starts.
19. As the developer, I want each spec's manual check to list the behaviours only a view shows (VoiceOver labels and traits, a control's first state, layout fit), one line per user story the tests can't reach, so that the simulator walk and my check on the shared project work from a list, not free exploration.
20. As the developer, I want every bug's tracker file to answer "why didn't the tests catch it?" before the fix, so that the suite's design improves instead of growing by one test per bug.
21. As the developer, I want the fix to close the cause it names (a missing behaviour in a spec, a missing test at the right layer, or a missing line in the manual check), so that the same kind of bug doesn't get through again.
22. As the developer, I want the existing 91 tests checked against these rules in this change, so that the suite starts clean.
23. As the developer, I want each deleted or merged test listed with its reason in the handover, so that I can veto any deletion.
24. As the developer, I want `TodayScreenTests`, `PetsScreenTests` and `NoHouseholdScreenTests` replaced by suites named after the units they test, or deleted where they only restate the code, so that no suite is named after a reference file.
25. As the developer, I want the fake server the data tests use called a stub, since its payloads are hand-written, so that its name doesn't claim they were recorded.
26. As the developer, I want the generated row types to stay the guard against schema drift, so that the hand-written payloads don't need recording against a real server.
27. As a Member, I want no one outside my Household to read my Household, its Members, its Pets, their events or their calendar events, so that my data stays private.
28. As a Member, I want no one outside my Household to add, edit or delete my Household's Pets or their events, or add calendar events to them, so that no one else can change my data.
29. As a Member, I want to read, add, edit and delete my Household's Pets and their events, and read and add their calendar events, so that the app can do what it promises.
30. As a Member, I want to be unable to move a Pet into a Household I'm not in, so that Pets can't be pushed into someone else's Household.
31. As a Member, I want to read my Household and every Member's membership in it, but not create Households or change memberships, so that only the dashboard sets up Households.
32. As a signed-out person, I want no access to any table, so that the database reveals nothing without an Account.
33. As the developer, I want those access rules checked by `supabase test db` on the local stack, so that a migration that breaks one fails before it reaches the shared project.
34. As the developer, I want each database test to create its own Accounts and Households in a transaction that's rolled back, so that changing `seed.sql` can't break it and tests don't affect each other.
35. As the developer, I want the database tests to run as the `authenticated` and `anon` roles with an Account's JWT claims, so that they check the rules as the apps meet them, not the helper functions behind them.
36. As the developer, I want `supabase test db` in the Supabase checks and in wrap-up for any change under `supabase/`, so that it runs whenever the schema can change.
37. As the developer, I want tests still to run at wrap-up, with the pre-commit hook running lint only and no CI, so that checks match a one-person project until a second client or contributor arrives.
38. As the developer, I want no UI or snapshot test targets for now, so that the suite stays fast and isn't brittle while the prototype changes.
39. As the developer, I want the Keychain storage to stay a simulator check until release (Phase 7), so that the test bundles don't need a host app yet.
40. As a contributor or agent, I want the testing philosophy stated once as an architecture principle, with the conventions applying it, so that I know why the rules exist and can judge a case they don't cover.
41. As the developer, I want ADR 0006 and the architecture principles to say every client tests the same spec behaviours, not ported Jest cases, so that no document contradicts the rest.

## Implementation Decisions

- **Scope:** rules, docs and the existing tests, plus a new pgTAP suite. No production behaviour changes. The only production-code edits are rewritten doc comments.
- **The philosophy, in `docs/architecture.md`:** a new Code principle, "Tests protect what the specs promise". Every test checks a behaviour a spec lists, through the unit's public interface, and stays only if a plausible wrong change would make it fail. The iOS and Supabase conventions link to it for the rules that apply it.
- **Shared rules across clients:** principle 7's "Every client runs the same rule cases" and ADR 0006's "ported case for case from the Expo app's tests" become "every client tests the same spec behaviours for each rule". ADR 0006 is edited in place: its decision (rules run on each client) is unchanged, only how drift is guarded is reworded. A shared case format still waits for Phase 8.
- **Test rules, in the iOS conventions' Tests section:**
  - Tests check behaviour through the unit's public interface. What crosses a boundary (store, auth, server) counts; doubles stand in only at those boundaries.
  - A test stays only if a plausible wrong change that still compiles would make it fail. No assertions on constants, defaults, literal copy or pass-throughs. Copy built by logic is tested for its branch.
  - One behaviour, one test, at the lowest layer that can show it.
  - A suite is named after the Swift unit it tests. A test is named after the spec behaviour it checks.
  - Code, tests and their comments never mention the reference app.
  - The Tests table's `KiwiDomain` row ("with the reference's test cases and names") changes to behaviours from the spec.
- **Spec-driven tests, in `CONTRIBUTING.md`:**
  - A spec's Testing Decisions list, by unit, the behaviours the automated tests cover, from its user stories.
  - Its manual check lists the behaviours only a view shows.
- **Bug fixes, in `CONTRIBUTING.md` under Plan:** a bug's tracker file answers "why didn't the tests catch it?" before the fix. The fix closes that cause: the spec, the suite or the manual check. There's no blanket rule of one regression test per bug.
- **`port-feature`:** step 1 reads the reference's tests to find behaviours for the spec, not as the specification itself. Step 2 drops "port their Jest tests … with the same case names and the same expectations" and "port it as it is". A reference test that looks wrong is raised with the developer while the spec is written. Its worked example names the stub server.
- **Migration plan:** the ground rule "Each port ships with its rules' tests ported case for case" becomes "each port ships with tests for the behaviours its spec lists".
- **Existing tests:**
  - Every suite and test is checked against the rules. Each one is kept, renamed, merged into another, or deleted.
  - Known cases:
    - The two header-title tests restate the code: delete them.
    - `startsReadyToSignOut` asserts defaults: delete it.
    - The no-household message test keeps only the missing-email branch, in a suite named after the unit that owns it. That screen's Check again and Sign out cases already belong to `HouseholdModelTests` and `SignOutModelTests`: drop them there if those suites already cover them.
    - `validatesAndSubmitsPetDetailsFormValues` is checked for overlap with the form's single-behaviour tests.
    - `pointsDevelopersToTheSetupSteps` is checked against the rule.
  - Suites built from several units are split by unit.
- **Stub server:** `RecordedSupabaseServer` becomes `StubSupabaseServer`, with the same interface. Payloads stay hand-written, and `make db-types` remains the drift guard.
- **Doc comments:** the 52 mentions of the reference in the KiwiKit sources, and those in the tests, are rewritten to describe the unit's behaviour. A comment that only justified matching the reference states the behaviour and its reason in the app's own terms, or goes.
- **Database tests:**
  - pgTAP files under the Supabase folder's tests directory, run by `supabase test db` on the local stack after `supabase db reset`.
  - Each file runs in a transaction it rolls back. It creates its own Auth users, Households, memberships and Pets as the superuser, then switches role and JWT claims to act as a member of the Household, a member of another Household, or a signed-out user (`anon`).
  - Plain pgTAP, no helper extension.
  - The cases are the access rules `docs/supabase.md` states, for `households`, `household_members`, `pets`, `pet_events` and `calendar_events`, across select, insert, update and delete where the role can attempt them:
    - visible versus hidden rows;
    - writes allowed versus refused;
    - updating a Pet into another Household refused;
    - creating Households and changing memberships refused for every app role;
    - signed-out access refused everywhere.
  - Storage (`pet-photos`) policies are tested with KIW-24, when the app first uses them.
- **Supabase conventions:** the Checks become `supabase db reset`, `supabase db lint`, then `supabase test db`. The conventions say each table's access rules have pgTAP tests, and that a migration changing a policy changes its tests.
- **Wrap-up:** runs `supabase test db` (after a reset) for any change under `supabase/`.
- **No schema change, no migration, no new ADR, no glossary change.**

## Testing Decisions

- **Good tests:** drive a unit as its caller does and check what the caller sees: state, returned values, errors, and what reached a boundary. Never check how the unit is built. A test earns its place only if a plausible wrong change would make it fail.
- **Seams:** the existing ones, plus one new one.
  - `KiwiDomain`: pure functions, "now" and a calendar as input, no doubles. Prior art: `PetDetailsTests`.
  - `KiwiData`: stores against `StubSupabaseServer`. Prior art: `SupabasePetStoreTests`, `SupabaseBackendTests`.
  - `KiwiFeatures`: models and forms over in-memory stores. Prior art: `PetsModelTests`, `HouseholdModelTests`.
  - New: the database through pgTAP, acting as the `authenticated` and `anon` roles. No prior art in the repo.
- **Behaviours covered by the new tests:** user stories 27–32, one pgTAP case per rule, role and operation that the rule constrains.
- **The cleanup's own check:** `make test` passes with fewer tests, and every behaviour a kept spec lists is still covered by a test. The handover lists each deletion and merge with its reason.
- **Manual check on the shared project:** none. The app's behaviour doesn't change and there's no migration. The developer reviews the deletion list and the rewritten rules.

## Out of Scope

- UI, snapshot or XCUITest targets.
- CI, or running tests in the pre-commit hook.
- A host app for the KiwiKit tests and Keychain tests (revisit before Phase 7).
- Storage policy tests (KIW-24).
- A shared rule-case format across clients (Phase 8).
- Recording payloads from a real server, or data tests against the local stack.
- Coverage targets.
- Rewriting existing specs' Testing Decisions or manual checks. New specs follow the rules from now on.

## Further Notes

- Why the suite missed each of the four bugs fixed so far, which is what user stories 19–21 address:
  - `kiwitracker://` URL handling nobody used (bug 01): code with no spec behind it, so not a failure the tests could catch.
  - A reinstall staying signed in (bug 02): no spec said a reinstall shows sign-in. The Expo app did it as a side effect of its storage, and the Keychain is untested.
  - VoiceOver reading ", selected pet" on a pet card: accessibility lives in the view, which no test reaches.
  - The date of birth calendar's first day, opening month, bound and fit (KIW-23): behaviour inside the `UICalendarView` wrapper, which has no tests, and KIW-23's spec didn't list it.
- `docs/supabase.md` already states the access rules in words, so it's the source for the pgTAP cases. If a test shows the database disagreeing with it, that's a bug to log, not a test to bend.
