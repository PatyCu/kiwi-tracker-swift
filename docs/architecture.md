# Architecture principles

The principles every change to Kiwi Tracker is checked against, on every client
and the backend. The decisions behind them are in [`docs/adr/`](adr/). A change
that breaks a principle needs a new ADR that changes the principle or records
the exception.

## Behavior

1. **The reference defines behavior, not structure.** Until it's retired, every
   client matches the Expo app's capabilities, flows, rules, copy, branding and
   empty, loading and error states. Its code structure, libraries, workarounds
   and names don't carry over: names, and copy naming a domain concept or a UI
   piece, come from the glossary and the client's conventions. Say the
   reference does something only after reading its code. ([ADR 0001](adr/0001-native-rebuild-with-a-behavior-reference.md))
2. **Platform-native.** Each client uses its platform's own components and
   conventions for its chrome. A custom control, or any other intentional
   difference from the reference, is confirmed by the developer and recorded
   in the feature's spec. Names and copy that principle 1 sets aren't such
   differences.

## System

3. **One backend, thin clients.** Clients talk to Supabase directly; there is
   no API server. Row-level security is the only authorization layer, and its
   helper functions alone decide who sees what.
   ([ADR 0003](adr/0003-row-level-security-is-the-authorization-layer.md))
4. **Online-only.** Household data lives in Supabase. A device keeps only its
   Session and a cache of pet photos: no offline writes, no sync.
   ([ADR 0004](adr/0004-online-only-clients.md))
5. **The schema is the contract.** Migrations are the source of truth. Each
   client generates its row types from the schema and maps them to its own
   domain model. While the Expo app runs, schema changes are additive.
   ([ADR 0005](adr/0005-one-supabase-project-shared-with-the-expo-app.md))
6. **Stored data stays readable.** A schema change keeps existing health data
   readable, or migrates it explicitly.

## Code

7. **Domain rules are pure.** Rules and validation have no UI and no I/O, take
   the time ("now" and a calendar) as input, and are tested without mocks.
   Every client tests the same spec behaviors for each rule.
   ([ADR 0006](adr/0006-domain-rules-run-on-each-client.md))
8. **Dependencies point inward.** UI and data both depend on the domain, never
   on each other. Only the data layer knows the backend and its row types, and
   only the composition root wires the layers together.
   ([ADR 0008](adr/0008-package-targets-enforce-the-dependency-rules.md))
9. **One responsibility per module.** Each module has one reason to change.
   Presentation, domain rules, persistence and external integrations stay
   separate. Don't split code only to shorten a file, or add an abstraction
   before a real boundary exists.
10. **Organize by domain concept.** One store per domain concept and one
    feature per product area, each named for what it is in the domain. A
    feature doesn't reach into another; what both need moves down to the
    domain or the design system. No `Utils`, `Helpers` or `Common`.
11. **Clear roles.** Screens compose components and coordinate screen-level
    state. Screen models hold what screens show and expose its operations.
    Stores are stateless, with typed inputs, outputs and errors. Dependencies
    are injected, so previews and tests run on in-memory stores.
12. **Explicit context.** Operations and routes take IDs, never objects or an
    ambient "current pet".
13. **User input survives failure.** A failed write keeps what the user entered
    and says what went wrong; nothing is discarded silently.
14. **Tests protect what the specs promise.** Every test checks a behavior a
    spec lists, through the unit's public interface, the way its caller sees
    it. A test stays only if a plausible wrong change that still compiles would
    make it fail, so a refactor that keeps the behavior keeps every test
    green. The [iOS conventions](../ios/CONVENTIONS.md#tests) say how the app's
    tests apply this.
