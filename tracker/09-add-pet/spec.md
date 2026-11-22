# Add a pet and edit its details (KIW-23)

Status: in-progress

## Problem Statement

A Member can see their Household's Pets on iOS but can't add one or change one's details. A Household without Pets sees "No pets yet" with no way forward. In the reference app, a sheet adds a Pet or edits its name, species, breed and date of birth, opened from the No pets yet card, from the "Add pet" card in the selector, and from each selector card's "Edit" link.

## Solution

A sheet titled "Add a pet" or "Edit pet" holds a native form: name, species (Cat, Dog, Other), breed and an optional date of birth. It opens from "Add your first pet" on the No pets yet card on Today and Pets, from a dashed "Add pet" card at the end of the selector row, and from an "Edit" button on each selector card. Saving adds the Pet to the Household or updates it, and the Pets on Today and Pets show it at once, in name order. If the save fails, the sheet stays open with an alert. The photo comes with KIW-24, and KIW-25 (the selector card's edit link) is folded into this feature.

## User Stories

1. As a Member of a Household without Pets, I want an "Add your first pet" button on the No pets yet card on the Pets tab, so that I can add one from where I learn there are none.
2. As a Member of a Household without Pets, I want the same button on Today's No pets yet card, so that the first tab I see lets me start.
3. As a Member of a Household with Pets, I want a dashed "Add pet" card, subtitled "Add details", at the end of the selector row, so that I can add another Pet.
4. As a Member using VoiceOver, I want the add card read as "Add another pet", so that I know what it does.
5. As a Member, I want an "Edit" button under each selector card's name, so that I can change that Pet's details.
6. As a Member using VoiceOver, I want the card's two buttons read as "{name}" (with Selected when it is) and "Edit {name}", so that I can tell selecting from editing.
7. As a Member, I want tapping "Edit" to open the sheet without changing the selected Pet.
8. As a Member adding a Pet, I want the sheet titled "Add a pet" with empty fields and Cat chosen, so that I start from a clean form.
9. As a Member editing a Pet, I want the sheet titled "Edit pet" with that Pet's details filled in.
10. As a Member, I want the name field focused when the sheet opens, so that I can type straight away.
11. As a Member, I want the name field's placeholder "e.g. Miso" and the breed field's "e.g. European shorthair", so that I know what goes there.
12. As a Member, I want to choose the species from Cat, Dog and Other in a segmented control.
13. As a Member, I want the date of birth optional, showing "Select date" until I choose one, so that I can add a Pet whose birthday I don't know.
14. As a Member, I want to clear a chosen date of birth, so that I can undo a wrong one.
15. As a Member, I want dates after today not to be choosable, so that a Pet can't be born in the future.
16. As a Member, I want the date of birth kept as the day I chose, whatever my time zone, so that it never shifts by a day.
17. As a Member, I want "Add" or "Save" disabled while the name is empty or only spaces, so that every Pet has a name.
18. As a Member, I want the name and breed saved without leading or trailing spaces.
19. As a Member, I want a breed left empty saved as no breed, and a cleared breed or date of birth removed from the Pet.
20. As a Member, I want a spinner in place of "Add" or "Save" while saving, and the sheet kept open until it finishes, so that I don't save twice or lose track of it.
21. As a Member, I want Cancel or swiping the sheet down to discard my changes without asking, as the reference does.
22. As a Member who adds a Pet, I want it to appear in the selector in name order, with my selected Pet still selected.
23. As a Member who adds the first Pet, I want the Pets tab to show it selected, and Today to show its usual content instead of the No pets yet card.
24. As a Member who edits a Pet, I want the selector to show its new name, in name order.
25. As a Member whose save fails, I want the sheet to stay open with what I entered and an alert, "Pet not added" or "Pet not updated", saying "The pet could not be confirmed as saved. Reopen the app before trying again."
26. As a Member editing a Pet that has meanwhile gone from the list, I want nothing saved and the failure alert shown, so that I never recreate or overwrite the wrong Pet.
27. As another Member of the same Household, I want the Pet added or edited on iOS to show up in the Expo app and on my next load, since both read the same Pets.
28. As a person signing in as another Account, I want the sheet to add Pets only to that Account's Household.
29. As a Member using Dynamic Type, I want the sheet, the add card and the Edit button to scale and wrap.
30. As a Member in light or dark appearance, I want the sheet and cards in the app's palette.

## Implementation Decisions

- **Glossary**: **Pet** now says it has a name and a species, and may have a breed and a date of birth. No new term; "profile" stays avoided.
- **Scope**: KIW-25 is folded in: its only piece is the selector card's edit link. Both lines are ticked off together in the migration plan.
- **Schema**: no change. `pets` has `name`, `species`, `breed` and `birth_date`, and Members can already add and edit their Household's Pets.
- **KiwiDomain**: `Pet` gains an optional breed and an optional date of birth. `PetDetails` holds what a Member enters: name, species, breed and date of birth (the reference's `PetProfile`). The date of birth is a calendar day (year, month, day), never a moment in time, and is valid when empty or no later than the device's today. `PetStore` gains `addPet(_:to:)`, which adds `PetDetails` to a Household and returns the stored Pet, and `updatePet(_:_:)`, which saves `PetDetails` to a Pet by id and returns it, with a `couldNotSave` error for both.
- **KiwiData**: `SupabasePetStore` reads `breed` and `birth_date` too. It inserts one row with the Household's id and updates by id, writing an empty breed or a missing date of birth as null, and selecting the stored row back, as the reference's `insertPet` and `updatePet`. The photo column is left for KIW-24.
- **State**: `PetsModel.save(…)` mirrors the reference's `saveProfile`. It takes the details and, when editing, the Pet's id. It adds to the signed-in Household (its id from the ready `HouseholdModel`) or updates the Pet, then puts the stored Pet into the ready list in name order, then id, leaving the selection as it is. Editing an id that isn't in the list fails without calling the store. The sheet opens only where the Pets are loaded.
- **Form**: `PetDetailsForm` in `Pets/Forms` mirrors `usePetProfileForm`. It opens empty with Cat, or with a Pet's details. It trims the name and breed before saving, can save only with a non-empty name, a valid date of birth and no save running, closes on success, and stays open on failure, reporting whether it was adding or editing so the sheet shows the right alert.
- **UI**:
  - `PetDetailsSheet` is a native sheet: a `NavigationStack` with a `Form`. Its title is "Add a pet" or "Edit pet", with Cancel on the left and "Add" or "Save" on the right. The fields are Name, Species, Breed and Date of birth.
  - While saving, the confirm button shows a spinner and the sheet can't be dismissed.
  - Swiping it down or tapping Cancel discards changes.
  - A failed save shows the alert from story 25.
  - `PetSpeciesPicker` is segmented.
  - `PetBirthDateField` shows "Select date" until a date is chosen, then a date-only picker capped at today, with a clear button that VoiceOver reads as "Clear date".
- **Entry points**:
  - `NoPetsCard` gains "Add your first pet" on both tabs.
  - `AddPetCard` is the dashed card after the selector cards, titled "Add pet" and subtitled "Add details", with "Add another pet" as its VoiceOver label.
  - `PetSelectorCard` becomes two sibling buttons: the select area and a muted "Edit" text button under the name, with "Edit {name}" as its VoiceOver label.
  - Today and Pets each present the sheet themselves.
- **Copy**: word for word from the reference, except where the reference says "profile", which the glossary avoids: "Create profile" → "Add details", "Edit profile for {name}" → "Edit {name}", "The profile could not be confirmed as saved." → "The pet could not be confirmed as saved."
- **Confirmed differences**, all confirmed by the developer:
  - The confirm button is in the toolbar and reads "Add" / "Save" with a spinner, where the reference has a full-width "Add pet" / "Save changes" / "Saving…" button at the bottom.
  - The date of birth is a native picker capped at today, so the reference's "Choose today or an earlier date." error can't appear and is left out, along with its DD-MM-YYYY text parsing.
  - A saved Pet goes into name order at once, where the reference appends it until the next load.
  - The selector card's "Edit" is a separate button without the reference's hover pencil.

## Testing Decisions

- **Good tests**: drive the form and the model the way the sheet does, and check what a Member sees (state, list order, selection, which alert) and what reaches the store. Don't check how either is built internally.
- **KiwiFeatures** (the main seam: `PetDetailsForm` over a real `PetsModel` and `RecordingPetStore`). Prior art: `PasswordSignInFormTests`, `PetsModelTests`.
  - Ported from the reference, case for case: "validates and submits pet profile form values" (a day as the date of birth); "adds a new pet to the household as one record"; "refuses to edit a pet that is no longer in the list"; "adds the first pet from the empty state when the household has none yet" (Pets and Today share the model, so one case); "opens the existing profile modal from the pet selector card" (opens for editing with the Pet's details, selection unchanged).
  - New: an empty or spaces-only name can't be saved; a date of birth after today can't be saved, and an empty one can; an empty breed is sent as none; the added Pet is in name order with the selection kept; an edited Pet is re-sorted; a failed save keeps the form open with its input and says whether it was adding or editing; nothing can be saved while a save runs.
- **KiwiData** (`SupabasePetStore` against `RecordedSupabaseServer`). Prior art: `SupabasePetStoreTests`.
  - Ported: "adds a pet to the given household as one row", "saves one pet by id and clears fields left empty", "wraps a failed write in a typed error".
  - Changed: "loads the household's pets by name" also reads breed and date of birth.
  - The photo case ("records where a pet photo is stored and touches nothing else") comes with KIW-24.
- **Previews**: `PetDetailsSheet` adding, editing and saving; the selector row with the add card and Edit buttons; the No pets yet card with its button; light and dark.
- **Simulator**: on the local stack, first as Riley (no Pets): add a first Pet from Today and from Pets. Then as a shared-household Account: add a Pet, edit one from its card, clear a breed and a date of birth, and check name order. Then on the shared project, and check the Pet in the Expo app.

## Out of Scope

- The photo picker, upload and photo alerts (KIW-24).
- The overview's edit action and the profile screen (KIW-26).
- Deleting a Pet.
- Confirming before discarding unsaved changes; the reference doesn't.

## Further Notes

- The reference's failure message asks to reopen the app because an add whose response is lost may still have saved; retrying could add the Pet twice. The port keeps that behavior rather than retrying.
