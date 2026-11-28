# Write the testing rules down

Status: done

From [the spec](../spec.md), Implementation Decisions. Write the rules down before anything applies them, so the cleanup and the database tests have something to follow. Only docs and skills change.

- `docs/architecture.md` gets a new Code principle, "Tests protect what the specs promise". Every test checks a behaviour a spec lists, through the unit's public interface, and stays only if a plausible wrong change would make it fail.
- Principle 7 and ADR 0006, edited in place, say that every client tests the same spec behaviours for each rule, instead of porting Expo test cases one for one. ADR 0006's decision itself doesn't change.
- The iOS conventions' Tests section carries the rules:
  - behaviour through the public interface, with doubles only at boundaries;
  - the "plausible wrong change" bar: no constants, defaults, literal copy or pass-throughs, and copy built by logic is tested for its branch;
  - one behaviour, one test, at the lowest layer that can show it;
  - suites named after their Swift unit, and tests named after the behaviour they check;
  - no mention of the reference app.

  The `KiwiDomain` row of the Tests table changes to "behaviours from the spec". The section links to the principle.
- `CONTRIBUTING.md` says a spec's Testing Decisions list, by unit, the behaviours the tests cover, and its manual check lists the behaviours only a view shows. Under Plan, a bug's tracker file answers "why didn't the tests catch it?" before the fix, and the fix closes that cause: the spec, the suite or the manual check.
- In `port-feature`, step 1 reads the reference's tests to find behaviours for the spec. Step 2 drops the "port their Jest tests case for case" and "port it as it is" wording. A reference test that looks wrong is raised while the spec is written. The worked example names `StubSupabaseServer`.
- The migration plan's ground rule becomes "each port ships with tests for the behaviours its spec lists".

- [ ] Every doc above states the rules, and none contradicts another (grep for "case for case" and "Jest" in docs and skills).
- [ ] No schema change, no new ADR, no glossary change.

## Comments

- 2026-11-28: Done. Principle 14 links to the iOS conventions only; ticket 04 adds the Supabase link. port-feature's worked example says "over the stub server" without naming the type, which ticket 02 renames. The docs use "behavior", as the repo already does.
