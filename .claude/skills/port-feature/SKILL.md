---
name: port-feature
description: Port a capability from the Expo reference app (.reference/kiwi-tracker) to the native iOS app, matching its rules, flows, copy and states. Use when starting or continuing a feature that brings a reference feature to iOS, or when asked to "port", "match" or "check parity" for a screen or feature.
---

# Port a feature

The Expo app at `.reference/kiwi-tracker` (pinned to `c6db92f`) is the reference. The iOS app matches
what it does and says; native components decide how the chrome looks. The
parity rule is principles 1 and 2 in `docs/architecture.md`; its exceptions are
ADRs in `docs/adr/`.

Porting is code, so it runs under `/implement`, once the developer has approved
the spec by running it (`AGENTS.md#workflow`).

If `.reference/kiwi-tracker` is missing, recreate it as `docs/migration-plan.md`
Phase 0 describes; never read or run `../kiwi-tracker` instead.

## 1. Read the reference

- Read it with absolute paths or `git -C .reference/kiwi-tracker`, keeping the
  working directory at the repo root.
- Find the capability's routes in `src/app`, its module in `src/modules/<area>`
  and anything it uses from `src/shared`. Its iOS home:

  | Expo (`src/…`)                             | iOS (`ios/KiwiKit/Sources/…`)                               |
  | ------------------------------------------ | ----------------------------------------------------------- |
  | `app/` (Expo Router)                       | `KiwiFeatures/AppShell` (tabs, stacks, `Route`, URLs)        |
  | `modules/*/model`, pure rule files         | `KiwiDomain`                                                |
  | `modules/*/persistence`, `shared/supabase` | `KiwiData`                                                  |
  | `modules/*/state` (providers)              | `KiwiFeatures/*/State` (`@Observable` models)               |
  | `modules/*/forms` (hooks)                  | `KiwiFeatures/*/Forms` (`@Observable` form models)          |
  | `modules/*/ui`                             | `KiwiFeatures/*/UI`                                         |
  | `shared/theme`, `shared/ui`                | `KiwiDesign`                                                |
  | `modules/pets/media`                       | `KiwiData` (cache, upload) + `KiwiFeatures/Pets` (picker)   |
- Read its tests to find behaviors for the spec; they aren't the
  specification themselves. Raise a reference test that looks wrong with the
  developer while the spec is written.
- List what a person sees: each screen and sheet, every string, and the
  loading, empty, error and Retry states.
- Extract its behaviours into `requirements/` as drafts, following
  `.claude/skills/requirements/SKILL.md`, for the developer to approve while
  the spec is written.

## 2. Port the rules first

- Port pure rules and validation to `KiwiDomain`, with tests for the
  behaviors the spec lists, following the Tests rules in `ios/CONVENTIONS.md`.

## 3. Data, state, UI

- Stores in `KiwiData` read and write the columns the reference does that this
  feature uses, with the same validation before writing. No schema change unless
  the feature's issue asks for one.
- The household load is the worked example of store, model and tests:
  `SupabaseHouseholdStore` and `SupabaseHouseholdStoreTests` (over
  `StubSupabaseServer`), `HouseholdModel`, `RecordingHouseholdStore` and
  `HouseholdModelTests`.
- Models in `KiwiFeatures/<Area>/State` mirror the reference provider's
  operations and load and retry behavior.
- Name types from `GLOSSARY.md` and the suffix list in `ios/CONVENTIONS.md`
  (UI), translating the reference's names: `SymptomModal` → `SymptomSheet`,
  `TimelineEvents` → `PetEventsSection`.
- Screens use native components. Copy every string verbatim from the reference,
  except that copy naming a domain concept or a UI piece uses its `GLOSSARY.md`
  term or its CONVENTIONS name. These names aren't differences to confirm or
  record (step 4).
  Add `#Preview`s for loaded, empty, loading and error.

## 4. Compare side by side

Required when the port adds or changes a screen's layout or a multi-step flow. For a
section of native rows (a `Form` section, a single button), compare the copy and every
state against the reference component and its test instead, and say so in the handover.

- Run the reference on the iOS Simulator (`npm ci`, then `npm run ios`, in `.reference/kiwi-tracker`)
  and the native app on the local stack, signed in as the same seeded account.
- Walk every flow from step 1 in both and compare screenshots: content, order,
  copy, states and what each action does. Chrome may differ where a native
  component replaces a custom one; nothing else may.
- Fix differences, or list the ones that are intentional for the developer to
  confirm, and record confirmed ones in the feature's spec (its GitHub issue)
  and as `Migration: changed` in its requirements.

## 5. Hand over

Continue with `CONTRIBUTING.md#validate` and the root `AGENTS.md` workflow:
checks, local validation, the developer's check on the shared project and
wrap-up.
