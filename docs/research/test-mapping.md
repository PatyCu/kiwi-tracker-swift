# Tests mapped to requirement IDs

Research for #9 (map #3). Facts only; the test-layer decision is a later grilling ticket.
Snapshot of `main` at `784c2c0`, 2026-11-28.

`req-coverage.sh report`: `Coverage: 0/0 active (110 draft)`. No ORPHAN, DROPPED BUT TESTED or
malformed sections. Every requirement is `draft`, so the script counts nothing as covered yet;
the tables below read the citations directly. 77 of 110 draft IDs are cited by at least one test,
33 by none.

## 1. Test targets and how they run

| Suite | Kind | Runs with | Files |
|---|---|---|---|
| `KiwiDomainTests` | Swift Testing, pure logic, no doubles | `make test` | `PetDetailsTests` |
| `KiwiFeaturesTests` | Swift Testing, models against in-memory `Recording*` stores and auth | `make test` | 10 suites |
| `KiwiDataTests` | Swift Testing, real `SupabaseBackend` and SDK against `StubSupabaseServer` (a `URLProtocol` with hand-written JSON); in-memory Session storage, temp-folder photo cache | `make test` | 7 suites |
| `supabase/tests/*.sql` | pgTAP, RLS and grants per role and operation | `supabase test db` (after `supabase db reset`), not `make test` | 6 files |

- `make test` (`ios/Makefile`) runs `xcodebuild test` on the `KiwiTracker` scheme, iPhone 17 Pro
  simulator, `OS=latest`; `ONLY=` maps to `-only-testing:`. The scheme's `TestAction` lists the
  three KiwiKit test targets directly. `KiwiTracker Shared` lists the same three.
- No `.xctestplan` exists. No CI workflow exists (`.github/` is absent).
- **No UI test target.** `project.pbxproj` has one target, the application; no `XCUITest` or
  `import XCTest` anywhere in `ios/`.
- **No Swift test runs against the local Supabase stack.** KiwiData tests never open a socket;
  `127.0.0.1:54321` appears only as a config string in `SupabaseConfigTests`.
- KiwiKit tests can't reach the Keychain (`errSecMissingEntitlement`, ios/CONVENTIONS.md), so the
  Keychain path behind AUTH-009/012/013/014 is only exercised on the simulator, by hand.

## 2. Which kind of test proves each cited ID today

Unit = Swift Testing in KiwiKit (Domain / Features with in-memory doubles / Data with the stub
server). Local stack = Swift against `supabase start`. UI = XCUITest. Neither of the last two exists,
so those columns are empty for every ID and are left out.

| ID | Domain | Features | Data (stub) | pgTAP | Note |
|---|---|---|---|---|---|
| AUTH-001 | | | ✓ | | |
| AUTH-002 | | ✓ | | | |
| AUTH-003 | | ✓ | | | |
| AUTH-004 | | ✓ | ✓ | | |
| AUTH-005 | | ✓ | | | partial, see §3 |
| AUTH-006 | | ✓ | | | partial, see §3 |
| AUTH-008 | | | ✓ | | config errors only; the "unavailable" screen is untested |
| AUTH-009 | | | ✓ | | in-memory storage, not Keychain |
| AUTH-010 | | | ✓ | | |
| AUTH-011 | | | ✓ | | |
| AUTH-012 | | | ✓ | | in-memory storage, not Keychain |
| AUTH-013 | | | ✓ | | in-memory storage, not Keychain |
| AUTH-016 | | | ✓ | | asserts `scope=local` |
| AUTH-017 | | ✓ | | | |
| AUTH-018 | | ✓ | | | |
| HH-001 | | ✓ | | | |
| HH-002 | | ✓ | ✓ | | |
| HH-003 | | ✓ | ✓ | | |
| HH-004 | | ✓ | | | |
| HH-005 | | ✓ | | | |
| HH-007 | | ✓ | | | |
| HH-012 | | | ✓ | | |
| HH-013 | | ✓ | ✓ | | sort asserted as the `order` query sent |
| HH-014 | | ✓ | | | |
| HH-015 | | | ✓ | | |
| HH-017 | | ✓ | ✓ | | |
| HH-018 | | ✓ | | | |
| HH-019 | | | | ✓ | |
| HH-020 | | | | ✓ | |
| HH-021 | | | | ✓ | |
| PET-001 | | ✓ | | | |
| PET-002 | | | ✓ | | sort asserted as the `order` query sent |
| PET-003 | | ✓ | | | |
| PET-005 | | ✓ | | | |
| PET-007 | | ✓ | ✓ | | |
| PET-008 | | ✓ | | | |
| PET-011 | | | ✓ | | |
| PET-016 | | ✓ | | | **cited, not asserted**, see §3 |
| PET-018 | | ✓ | | | |
| PET-019 | ✓ | ✓ | | | |
| PET-020 | ✓ | | | | |
| PET-021 | ✓ | ✓ | ✓ | | |
| PET-022 | ✓ | ✓ | ✓ | | "Select date" placeholder untested |
| PET-023 | ✓ | ✓ | | | |
| PET-024 | ✓ | | | | |
| PET-025 | | ✓ | | | sheet not dismissable is untested (view) |
| PET-027 | | ✓ | | | |
| PET-028 | | ✓ | | | Today's card dropping is untested (view) |
| PET-029 | | ✓ | ✓ | | |
| PET-030 | | ✓ | | | |
| PET-031 | | ✓ | ✓ | | |
| PET-033 | | | | ✓ | |
| PET-034 | | | | ✓ | |
| PET-035 | | | | ✓ | |
| PHOTO-004 | | ✓ | | | partial, see §3 |
| PHOTO-005 | | ✓ | | | |
| PHOTO-006 | | ✓ | | | |
| PHOTO-007 | | ✓ | | | |
| PHOTO-008 | | ✓ | | | partial, see §3 |
| PHOTO-009 | | ✓ | | | |
| PHOTO-010 | | ✓ | | | partial, see §3 |
| PHOTO-011 | | | ✓ | | |
| PHOTO-012 | | ✓ | ✓ | | order asserted only in Features |
| PHOTO-013 | | ✓ | | | |
| PHOTO-014 | | ✓ | | | |
| PHOTO-015 | | ✓ | | | |
| PHOTO-016 | | ✓ | | | |
| PHOTO-017 | | ✓ | ✓ | | order asserted only in Features |
| PHOTO-018 | | ✓ | | | |
| PHOTO-020 | | ✓ | ✓ | | |
| PHOTO-021 | | ✓ | ✓ | | |
| PHOTO-022 | | | ✓ | | asserts a new path is fetched (`CachedPetPhotoStore`) |
| PHOTO-023 | | ✓ | ✓ | | |
| PHOTO-024 | | ✓ | ✓ | | |
| PHOTO-026 | | | | ✓ | |
| PHOTO-027 | | | | ✓ | |
| PHOTO-028 | | | | ✓ | |

**No test (33):** AUTH-007, 014, 015, 019, 020 · HH-006, 008, 009, 010, 011, 016 ·
SET-001 to 006 · PET-004, 006, 009, 010, 012, 013, 014, 015, 017, 026, 032 ·
PHOTO-001, 002, 003, 019, 025. Most are view-level (copy, layout, VoiceOver, sheets, tab
reset); AUTH-014 is a Keychain attribute; HH-008, PET-009 and PET-010 are cross-model wiring at
sign-in.

## 3. Tests citing an ID they don't (fully) assert

| ID | Test | What's asserted | What's missing |
|---|---|---|---|
| PET-016 | `PetDetailsFormTests.opensWithThePetsDetailsWhenEditing` | the edit form's prefill (that's PET-018) | the Edit button, its "Edit ‹name›" label, the selection staying unchanged: nothing |
| AUTH-006 | `PasswordSignInFormTests.signsInWithTheNormalizedEmailAndThePasswordAsTyped` | `signingIn` stays true after a submit | no second submit, so "further taps start nothing" is unasserted |
| AUTH-005 | `PasswordSignInFormTests.showsAnErrorAndLetsThePersonTryAgainWhenSignInFails` | editing the password clears the error | editing the email |
| PHOTO-008 | `PreparedPetPhotoTests.scalesAPhotoDownTo512pxAndStoresItAsJPEG` | 512×512, JPEG | that it's the centre square (3000×4000 in, no pixel check) |
| PHOTO-004 | `PetDetailsFormPhotoTests.showsThePickedPhotoAsStoredAndSavesOnlyTheLastOne` | shown photo has the stored width | centre crop |
| PHOTO-010 | `PreparedPetPhotoTests.storesAPhotoWithoutItsLocation` | GPS dictionary removed | camera metadata (EXIF/TIFF), which the requirement also names |

## 4. Tests asserting behaviour with no requirement ID

Suggested titles are not requirements; they go to the area's approval grilling.

| Test | Asserts | Suggested draft title / existing ID |
|---|---|---|
| `SessionModelTests.isLoadingUntilTheStoredSessionHasBeenRead` | loading until the stored Session is read | "The app waits for the stored Session before showing anything" (near AUTH-010) |
| `SessionModelTests.followsSignInAndSignOut` | state follows sign-in and sign-out | "Signing in opens the app and signing out shows sign-in" (near AUTH-001, AUTH-019) |
| `SessionModelTests.keepsTheSameStateWhenATokenRefreshReportsTheSameUser` | a refresh for the same user changes nothing | "A Session refresh doesn't reset the app" |
| `SessionModelTests.signsOutThroughAuth` | sign-out reaches auth | plumbing for AUTH-016 |
| `SessionModelTests.unsubscribesWhenObservingStops` | unsubscribes on cancel | internal; no requirement |
| `MembersModelTests.ignoresAnEarlierLoadThatFinishesLast` | latest Members load wins | "Only the latest Members load counts" (HH-007's twin) |
| `SelectedPetTests.selectsNothingWithoutPets` | no Pets, no selection | part of PET-003/PET-012 |
| `SupabaseConfigTests.returnsTheTrimmedURLAndPublishableKey` | config values trimmed | developer setup; arguably not app behaviour |
| `SupabaseHouseholdStoreTests.returnsTheSignedInAccountsHousehold` | query and row mapping | HH-001 (data side) |
| `SupabasePetPhotoStoreTests.wrapsARefusedUploadInATypedError` | upload failure typed | supports PHOTO-014 |
| `SupabasePetPhotoStoreTests.wrapsAFailedDeleteInATypedError` | delete failure typed | supports PHOTO-018 |
| `SupabasePetPhotoStoreTests.downloadsAPhotoByPathThroughTheSession` | download by path | supports PHOTO-019/021 |
| `SupabasePetPhotoStoreTests.wrapsAFailedDownloadInATypedError` | download failure typed | supports PHOTO-023 |
| `CachedPetPhotoStoreTests.fetchesAgainOnceTheFileIsRemoved` | removing a photo drops it from the device cache | "A deleted photo leaves the device too" (near PHOTO-017) |
| `pet_events_test.sql` (13 cases) | members read, add, edit, delete their Pets' events; outsiders and signed-out can't, outsiders can't move an event onto the Pet | "Members manage their Household's Pet events", "Outsiders can't reach a Household's Pet events", "Signed-out people can't reach any Pet event" |
| `calendar_events_test.sql` (12 cases) | members read and add; nobody edits or deletes; outsiders and signed-out reach nothing | "Members read and add their Household's calendar events", "Calendar events can't be edited or deleted", "Outsiders can't reach…", "Signed-out people can't reach…" |

The two event files have no area or prefix in `docs/requirements/README.md` yet (Pet events,
Calendar). Helpers (`Recording*`, `StubSupabaseServer`, `TestPhoto`) hold no tests.

## Sources

`.claude/skills/req-coverage/scripts/req-coverage.sh`, `docs/requirements/*.md`,
`ios/KiwiKit/Package.swift`, `ios/Makefile`, `ios/KiwiTracker.xcodeproj` (schemes,
`project.pbxproj`), `ios/CONVENTIONS.md` (Tests, Checks), `supabase/CONVENTIONS.md` (Checks),
every file under `ios/KiwiKit/Tests/` and `supabase/tests/`.
