# Bring the existing iOS suite in line

Status: done
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

- [x] `make test` passes.
- [x] Every behaviour a kept spec lists is still covered by a test.
- [x] No suite is named after a reference file, and no test or test comment mentions the reference.
- [x] The handover lists each deleted or merged test with its reason, so the developer can veto it.

## Comments

- 2026-11-28 (from 01): With the rename, update the `KiwiData` row of the iOS conventions' Tests table ("Recorded JSON payloads" becomes stub payloads), name `StubSupabaseServer` in port-feature's worked example, and fix the `make test ONLY=KiwiFeaturesTests/TodayScreenTests` example in the iOS conventions' Checks if that suite goes.
- 2026-11-28: Done. 91 tests became 80. Deleted: the two header-title tests and `startsReadyToSignOut` (restate the code); `NoHouseholdScreenTests.checksAgainAndSignsOut` and `saysSoWhenSigningOutFails` (covered by `HouseholdModelTests`, `SessionModelTests` and `SignOutModelTests`); `HouseholdModelTests.loadsAgainForADifferentAccount…` (it only showed two model instances are independent; the new model per sign-in is `RootView`'s); `PetDetailsFormTests.opensEmptyWithCatWhenAdding` (asserts defaults); `SupabaseConfigTests.pointsDevelopersToTheSetupSteps` (a constant hint on every error). Merged: `validatesAndSubmitsPetDetailsFormValues` into `addsANewPetToTheHouseholdAsOneRecord`; `cannotSaveWithoutAName` and `cannotSaveADateOfBirthAfterToday` into `blocksSaveWhileTheDetailsAreInvalid` (the cases stay in `PetDetailsTests`); `failsWhenAStoredPetIsInvalid` into `failsWhenThePetsCannotLoad`; `treatsUnexpectedErrorsAsUnknown` into `givesEachSignInProblemItsOwnMessage`. Split: `PetSelectionTests` became `SelectedPetTests`; the no-household message's test is `NoHouseholdMessageTests`. Kept: `SessionModelTests.isLoadingUntilTheStoredSessionHasBeenRead`, as a wrong first state would show sign-in before the stored Session is read. Copy assertions now check the branch (an error is shown, messages differ, the config error names its xcconfig key), not the words.
