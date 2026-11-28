# Pets and their details

### PET-001: Pets shows every Pet in the Household
Status: draft
Migration: same
Source: src/modules/pets/ui/PetSelector.tsx

The Pets tab shows one selector card per Pet in the Household, under "Choose the pet you want to manage."
Note: the reference says "profile" where the glossary says Pet.

### PET-002: Pets are sorted by name
Status: draft
Migration: same
Source: src/modules/pets/persistence/petStore.ts

Pets appear sorted by name, the same on every device.

### PET-003: The first Pet is selected by default
Status: draft
Migration: same
Source: src/modules/pets/ui/PetsScreen.tsx

Opening Pets selects the first Pet, and keeps a Pet once it's selected.

### PET-004: Tapping a card selects its Pet
Status: draft
Migration: same
Source: src/modules/pets/ui/PetSelectorCard.tsx

Tapping a selector card selects its Pet without leaving the tab, and only the selected card shows a checkmark.

### PET-005: A selected Pet that's gone falls back to the first
Status: draft
Migration: same
Source: src/modules/pets/ui/PetsScreen.tsx

When the selected Pet is no longer in the list, the first Pet is selected.

### PET-006: Pets and Today wait for the Pets
Status: draft
Migration: same
Source: src/app/_layout.tsx

Pets and Today show loading until the Household's Pets have loaded at sign-in.

### PET-007: A failed Pets load offers Retry
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

When the Pets can't be loaded, Pets and Today show the load error with Retry, and Retry shows loading again and reloads both tabs.

### PET-008: Only the latest Pets load counts
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

When loads overlap, an earlier Pets load that finishes last doesn't replace a later one.

### PET-009: A new membership brings its Pets
Status: draft
Migration: same
Source: src/app/_layout.tsx

The Household's Retry and "Check again" reload the Pets too, so an Account just added to a Household sees its Pets.

### PET-010: Each sign-in sees only its own Household's Pets
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

After signing in as another Account, the app shows only that Account's Household's Pets.

### PET-011: An unknown species fails the load
Status: draft
Migration: same
Source: src/modules/pets/persistence/petStore.ts

A stored Pet whose species isn't Cat, Dog or Other makes the whole Pets load fail rather than guess.

### PET-012: Pets says when there are no Pets
Status: draft
Migration: same
Source: src/modules/pets/ui/NoPetsCard.tsx

A Household without Pets sees, on Pets, "No pets yet" and "Add a pet to keep their profile, photo and health history together."

### PET-013: Today says when there are no Pets
Status: draft
Migration: same
Source: src/modules/pets/ui/NoPetsCard.tsx

A Household without Pets sees, on Today, "No pets yet" and "Add a pet to see how they're doing today and log what happens."

### PET-014: The first Pet is added from the No pets yet card
Status: draft
Migration: same
Source: src/modules/pets/ui/NoPetsCard.tsx

"Add your first pet" on the No pets yet card, on Today and Pets, opens the add sheet.

### PET-015: Another Pet is added from the selector row
Status: draft
Migration: changed
Source: src/modules/pets/ui/PetSelector.tsx

A dashed "Add pet" card, subtitled "Add details", ends the selector row and opens the add sheet; VoiceOver reads it as "Add another pet".

### PET-016: A Pet is edited from its selector card
Status: draft
Migration: changed
Source: src/modules/pets/ui/PetSelectorCard.tsx

Each selector card has an "Edit" button, read as "Edit ‹name›", that opens the edit sheet without changing the selected Pet.

### PET-017: The add sheet starts empty with Cat
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

The add sheet is titled "Add a pet", with every field empty and Cat chosen.

### PET-018: The edit sheet starts with the Pet's details
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

The edit sheet is titled "Edit pet", with the Pet's name, species, breed and date of birth filled in.

### PET-019: A Pet needs a name
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

"Add" and "Save" stay disabled while the name is empty or only spaces.

### PET-020: Name and breed are saved trimmed
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

A Pet's name and breed are saved without spaces at either end.

### PET-021: An empty breed is saved as no breed
Status: draft
Migration: same
Source: src/modules/pets/persistence/petStore.ts

A breed left empty, or cleared, is saved as no breed.

### PET-022: A date of birth is optional and can be cleared
Status: draft
Migration: same
Source: src/modules/pets/profile/usePetProfileForm.ts

The date of birth shows "Select date" until chosen, and clearing it removes it from the Pet.

### PET-023: A date of birth can't be after today
Status: draft
Migration: changed
Source: src/modules/pets/profile/usePetProfileForm.ts

Only today or an earlier day can be chosen as a date of birth.
Note: the reference accepts typed dates and shows "Choose today or an earlier date."; iOS caps its picker instead.

### PET-024: A date of birth keeps its day in any time zone
Status: draft
Migration: same
Source: src/modules/pets/model/Pet.ts

A date of birth is saved and shown as the calendar day chosen, whatever the device's time zone.

### PET-025: Saving shows progress and can't be repeated
Status: draft
Migration: changed
Source: src/modules/pets/ui/PetProfileModal.tsx

While a save runs, "Add" or "Save" shows a spinner, the sheet can't be dismissed and no second save starts.

### PET-026: Cancel discards changes without asking
Status: draft
Migration: same
Source: src/modules/pets/ui/PetProfileModal.tsx

Cancel or swiping the sheet down closes it and discards every change, without a confirmation.

### PET-027: A saved Pet appears at once in name order
Status: draft
Migration: changed
Source: src/modules/pets/state/PetsProvider.tsx

An added or edited Pet shows on Pets and Today straight away, in name order, with the selected Pet still selected.
Note: the reference appends an added Pet until the next load.

### PET-028: The first Pet added replaces the No pets yet card
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

Adding a Household's first Pet shows it selected on Pets, and Today drops the No pets yet card.

### PET-029: A failed save keeps the sheet open with an alert
Status: draft
Migration: changed
Source: src/modules/pets/profile/savePetProfile.ts

A failed save keeps the sheet open with what was entered and shows "Pet not added" or "Pet not updated" with "The pet could not be confirmed as saved. Reopen the app before trying again."
Note: the reference says "profile" where the glossary says Pet.

### PET-030: Editing a Pet that's gone saves nothing
Status: draft
Migration: same
Source: src/modules/pets/state/PetsProvider.tsx

Saving the edit of a Pet no longer in the list saves nothing and shows the "Pet not updated" alert.

### PET-031: Each Pet is added once to the signed-in Household
Status: draft
Migration: same
Source: src/modules/pets/persistence/petStore.ts

Adding a Pet stores it once, in the signed-in Account's Household.

### PET-032: Selector cards are read with the Pet's name
Status: draft
Migration: changed
Source: src/modules/pets/ui/PetSelectorCard.tsx

VoiceOver reads each selector card as the Pet's name, with Selected on the selected one.

### PET-033: Members manage their Household's Pets
Status: draft
Migration: same
Source: supabase/migrations

A Member can read, add, edit and delete their Household's Pets, and can't move a Pet to a Household they aren't in.

### PET-034: Outsiders can't reach a Household's Pets
Status: draft
Migration: same
Source: supabase/migrations

A Member of another Household can't read, add, edit or delete a Household's Pets.

### PET-035: Signed-out people can't reach any Pet
Status: draft
Migration: same
Source: supabase/migrations

A signed-out person can't read, add, edit or delete any Pet.
