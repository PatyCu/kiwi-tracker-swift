# Pet events

### EVT-001: Add event offers Diet change, Symptom and Other
Status: draft
Migration: same
Source: src/modules/pet-events/ui/QuickLog.tsx

The Add event row shows Diet change, Environment, Symptom, Treatment and Other, in that order, and only Diet change, Symptom and Other can be tapped.
Note: Environment and Treatment are shown disabled as placeholders.

### EVT-002: Add event actions are read as adding to the timeline
Status: draft
Migration: same
Source: src/modules/pet-events/ui/QuickLog.tsx

VoiceOver reads each Add event action as "Add ‹action› to timeline", such as "Add symptom to timeline".

### EVT-003: Add event on a Pet's overview logs for that Pet
Status: draft
Migration: same
Source: src/modules/pets/ui/PetOverview.tsx

An action in a Pet's overview Add event row opens its sheet for that Pet, with no Pet field.

### EVT-004: Add event on Today logs for the only Pet
Status: draft
Migration: same
Source: src/modules/today/ui/TodayQuickLogCard.tsx

In a Household with one Pet, an action in Today's Add event row opens its sheet for that Pet, with no Pet field.

### EVT-005: Add event on Today asks which Pet
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

In a Household with several Pets, a sheet opened from Today's Add event row shows a Pet field with the first Pet chosen, and the Pet event is logged for the Pet chosen there.

### EVT-006: Today has no Add event without Pets
Status: draft
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

A Household without Pets sees no Add event row on Today.

### EVT-007: A new log sheet starts fresh at the current time
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useSymptomForm.ts

Each log sheet opens empty, with today's date and the current time, even when a previous one was closed unfinished.

### EVT-008: The symptom sheet starts on Vomiting
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useSymptomForm.ts

"Log a symptom" offers Vomiting, Diarrhea, Asthma, Hairball, Nausea, Loss of appetite and Other as one choice, with Vomiting chosen.

### EVT-009: A Symptom is logged with its kind, time and note
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

"Save event" logs one Symptom for the Pet with the chosen symptom, date, time and note.

### EVT-010: Notes are saved trimmed, and an empty note as none
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

A Pet event's note is saved without spaces at either end, and a note that's empty or only spaces is saved as no note.

### EVT-011: An Other event needs a title
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useOtherEventForm.ts

"Log another event" keeps "Save event" disabled while "What happened?" is empty or only spaces.

### EVT-012: An Other event's title is trimmed and capped
Status: draft
Migration: same
Source: src/modules/pet-events/ui/OtherEventModal.tsx

An Other event's title takes at most 80 characters and is saved without spaces at either end.

### EVT-013: An Other event is logged with its title, time and note
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

"Save event" on "Log another event" logs one Other event for the Pet with its title, date, time and note.

### EVT-014: A Diet change is added, switched or stopped
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DietChangeModal.tsx

"Log a diet change" offers "Added an item", "Switched an item" and "Stopped an item", with "Added an item" chosen.

### EVT-015: An added item needs a product name and food type
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

Adding an item needs a product name that isn't only spaces, and a food type of Dry food, Wet food, Snack, Supplement or Other, with Dry food chosen.

### EVT-016: A diet item's product name is saved trimmed
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

A diet item's product name is saved without spaces at either end.

### EVT-017: Switching an item names what it replaced
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

"Switched an item" needs one item of the Pet's current diet chosen under "What did this replace?" and a new product name and food type.

### EVT-018: Stopping an item names what was stopped
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

"Stopped an item" needs one item of the Pet's current diet chosen under "What did you stop?", and asks for no product name or food type.

### EVT-019: Switching needs a current diet
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DietChangeModal.tsx

"Switched an item" can't be chosen while the Pet's current diet is empty.

### EVT-020: Stopping with no current diet says so
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DietChangeModal.tsx

"Stopped an item" with an empty current diet shows "No current diet items have been recorded yet." and keeps "Save diet change" disabled.

### EVT-021: Switching or stopping preselects the first current item
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

When "Log a diet change" opens, the Pet's first current diet item is chosen for "Switched an item" and "Stopped an item".
Note: possible bug, confirm: the reference preselects from the diet of the Pet the sheet last opened for, so a different Pet starts with nothing chosen.

### EVT-022: Choosing another Pet needs the item chosen again
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

Choosing another Pet in the diet change sheet lists that Pet's current diet and keeps "Save diet change" disabled for a switch or stop until one of its items is chosen.

### EVT-023: A Diet change is logged at its effective date and time
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

"Save diet change" logs one Diet change for the Pet at the chosen effective date and time, with its note.

### EVT-024: The current diet replays the Pet's Diet changes
Status: draft
Migration: same
Source: src/modules/pet-events/model/getCurrentDiet.ts

A Pet's current diet is every item added or switched to, minus every item switched from or stopped, in the order the Diet changes happened, and earlier-logged first when two happened at the same moment.

### EVT-025: Each Pet has its own current diet
Status: draft
Migration: same
Source: src/modules/pet-events/model/getCurrentDiet.ts

A Pet's current diet holds only its own Diet changes.

### EVT-026: A future Diet change counts from its time
Status: draft
Migration: same
Source: src/modules/pet-events/model/getCurrentDiet.ts

A Diet change dated in the future isn't part of the current diet until its date and time arrive.

### EVT-027: Items with the same name stay separate
Status: draft
Migration: same
Source: src/modules/pet-events/application/addDietItemIds.ts

Each added or switched-to item is its own diet item, so stopping one doesn't stop another with the same product name.

### EVT-028: A Pet event can be dated in the future
Status: draft
Migration: same
Source: src/shared/ui/date-time/DateTimePickerField.tsx

Every Pet event date and time picker accepts any date, past or future.
Note: possible bug, confirm: Symptoms and Other events can be logged in the future; only the Diet change sheet calls its date "effective".

### EVT-029: An impossible date and time blocks saving
Status: draft
Migration: same
Source: src/shared/dates/dateTime.ts

A date and time that doesn't exist on the device's clock, such as one skipped by a daylight-saving change, shows "Choose a valid date and time." and keeps saving disabled.

### EVT-030: A Pet event's time is the device's local time
Status: draft
Migration: same
Source: src/shared/dates/dateTime.ts

A Pet event is saved at the chosen date and time in the device's time zone, and shown in the time zone of the device viewing it.

### EVT-031: Logging shows progress and can't be repeated
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useSymptomForm.ts

While a log or edit saves, its button reads "Saving…", the sheet can't be closed, and no second save starts.

### EVT-032: A logged Pet event appears at once
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

A saved Pet event closes its sheet and shows straight away in the Pet's timeline, on Today and in the current diet.

### EVT-033: A failed log keeps the sheet open with an alert
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

A failed log keeps the sheet open with what was entered, adds nothing, and shows "Symptom not saved", "Diet change not saved" or "Event not saved" with "Please try again."

### EVT-034: Closing an unchanged sheet doesn't ask
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

Cancel, swiping down or tapping outside a Pet event sheet with no changes closes it at once.

### EVT-035: Closing a changed sheet asks to discard
Status: draft
Migration: same
Source: src/shared/platform/dialogs.ts

Closing a Pet event sheet with changes asks "Discard this symptom?", "Discard this diet change?", "Discard this event?", "Discard your changes?" or "Discard date and time changes?" with "Your changes will not be saved.", "Keep editing" and "Discard".

### EVT-036: Pet events load with the Pets at sign-in
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

At sign-in the app loads every Pet event of the Household's Pets, and Today and a Pet's overview show loading until they have loaded.

### EVT-037: A failed Pet events load offers Retry
Status: draft
Migration: same
Source: src/shared/ui/LoadState.tsx

When the Pet events can't be loaded, Today and a Pet's overview show "Could not load your data", "Check your connection and try again.", "Your saved data has not been changed." and Retry.

### EVT-038: Retry reloads only what failed
Status: draft
Migration: same
Source: src/modules/pet-events/state/usePetsAndEventsLoad.ts

Retry loads again only the Pets or Pet events that failed, keeping what already loaded.

### EVT-039: Each sign-in sees only its Household's Pet events
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

After signing in as another Account, the app shows only that Account's Household's Pet events, never the previous Account's.

### EVT-040: A malformed stored Pet event fails the load
Status: draft
Migration: same
Source: src/modules/pet-events/persistence/petEventStore.ts

A stored Pet event with an unknown type, symptom, food type or a missing field makes the whole Pet events load fail rather than show it.

### EVT-041: Nothing is logged before the Pet events load
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

Logging, editing or deleting a Pet event while the Pet events haven't loaded saves nothing.

### EVT-042: A Pet's timeline lists its Pet events newest first
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

A Pet's overview shows, under "Recent timeline", every Pet event of that Pet, newest first by when it happened.

### EVT-043: An empty timeline says so
Status: draft
Migration: same
Source: src/modules/pet-events/ui/TimelineEvents.tsx

A Pet without Pet events shows "No events for ‹name›" and "Use an add button above to log the first observation."

### EVT-044: A Symptom reads as logged
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

A Symptom is titled "‹symptom› logged", such as "Vomiting logged", and an Other symptom "Symptom observation".

### EVT-045: A Diet change reads as Added, Switched to or Stopped
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

A Diet change is titled "Added ‹product›", "Switched to ‹product›" or "Stopped ‹product›".

### EVT-046: A switch says what it replaced
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

A switched Diet change shows "Replaced ‹product›." before its note.

### EVT-047: An Other event reads as its title
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

An Other event is titled with its own title.

### EVT-048: A Pet event's time reads Today, Yesterday or its date
Status: draft
Migration: same
Source: src/shared/dates/dateTime.ts

A Pet event's time reads "Today · ‹time›", "Yesterday · ‹time›" or "‹day› ‹short month› · ‹time›", in the device's time format.
Note: possible bug, confirm: the date has no year, so a Pet event from an earlier year reads like this year's.

### EVT-049: A timeline entry shows its note
Status: draft
Migration: same
Source: src/modules/pet-events/ui/TimelineEvents.tsx

A timeline entry shows its Pet event's note below its time, and nothing when there's no note.

### EVT-050: Each kind has its own icon and colour
Status: draft
Migration: same
Source: src/modules/pet-events/timeline/toTimelineEntries.ts

Symptoms, Diet changes and Other events each show their own icon and colour in the timeline and on the event detail.

### EVT-051: Export for vet is shown as coming soon
Status: draft
Migration: same
Source: src/modules/pet-events/ui/PetActivityCard.tsx

"Recent timeline" shows a disabled "Export for vet · Coming soon".

### EVT-052: Tapping an entry's title opens its detail
Status: draft
Migration: same
Source: src/modules/pets/ui/PetOverview.tsx

Tapping a timeline entry's title opens that Pet event's detail.

### EVT-053: The event detail shows the Pet event
Status: draft
Migration: same
Source: src/modules/pet-events/ui/PetEventDetailScreen.tsx

The event detail, titled "Event detail" with the Pet's name, shows the Pet's photo and name, the Pet event's icon, title, time and note, "Edit event" and "Delete event".

### EVT-054: The event detail links to the Pet's overview
Status: draft
Migration: same
Source: src/modules/pet-events/ui/PetEventDetailScreen.tsx

"View pet overview" under the Pet's name on the event detail opens that Pet's overview.

### EVT-055: The event detail waits for the data
Status: draft
Migration: same
Source: src/modules/pet-events/ui/PetEventDetailScreen.tsx

The event detail shows loading, or the load error with Retry, until the Pets and Pet events have loaded.

### EVT-056: A missing Pet event's detail says it's unavailable
Status: draft
Migration: same
Source: src/modules/pet-events/ui/PetEventDetailScreen.tsx

The detail of a Pet event or Pet that no longer exists shows "Event not found", "This event is unavailable" and "It may have been removed from this device."
Note: possible bug, confirm: deleting from the detail leaves this screen showing instead of going back, and "from this device" is wrong for Household data.

### EVT-057: Edit event opens the Pet event's sheet filled in
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

"Edit event" opens "Edit symptom", "Edit diet change" or "Edit event" with the Pet event's details, date, time and note, and no Pet field.

### EVT-058: An edit keeps its Pet and kind
Status: draft
Migration: same
Source: src/modules/pet-events/model/PetEvent.ts

Editing a Pet event never changes its Pet or whether it's a Symptom, Diet change or Other event.

### EVT-059: Saving an edit needs a change
Status: draft
Migration: same
Source: src/modules/pet-events/ui/SymptomModal.tsx

"Save changes" stays disabled until something in the edit sheet differs from the Pet event.

### EVT-060: A Symptom edit corrects its kind, time and note
Status: draft
Migration: same
Source: src/modules/pet-events/application/applyPetEventEdit.ts

"Save changes" on a Symptom saves its chosen symptom, date, time and note.

### EVT-061: An Other event edit corrects its title, time and note
Status: draft
Migration: same
Source: src/modules/pet-events/application/applyPetEventEdit.ts

"Save changes" on an Other event saves its trimmed title, date, time and note, and an empty title can't be saved.

### EVT-062: A cleared note is removed
Status: draft
Migration: same
Source: src/modules/pet-events/application/applyPetEventEdit.ts

Clearing a Pet event's note in an edit removes the note.

### EVT-063: A Diet change edit keeps what changed fixed
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DietChangeModal.tsx

"Edit diet change" shows what changed as fixed text, "Added an item", "Switched an item, replacing ‹product›" or "Stopped an item: ‹product›", and only the introduced item, time and note can be corrected.

### EVT-064: Correcting a diet item corrects it everywhere
Status: draft
Migration: same
Source: src/modules/pet-events/application/applyPetEventEdit.ts

Correcting an added or switched-to item's product name or food type also corrects that item in the Pet's other Diet changes, as "Correcting an item also updates it everywhere else in the diet history." says.

### EVT-065: A stop edit corrects only its time and note
Status: draft
Migration: same
Source: src/modules/pet-events/forms/useDietChangeForm.ts

"Edit diet change" on a stopped item asks for no product name or food type.

### EVT-066: A saved edit shows at once
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

A saved edit closes the sheet and shows straight away in the timeline, the event detail, Today and the current diet.

### EVT-067: A failed edit keeps the sheet open with an alert
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

A failed edit keeps the sheet open with the edits and shows "Changes not saved" with "The event still has its earlier details. Your edits are still in the form; please try again."
Note: possible bug, confirm: when a diet item correction fails part-way, the Diet changes already saved keep the correction, so the message isn't true.

### EVT-068: Tapping an entry's time changes its date and time
Status: draft
Migration: same
Source: src/modules/pet-events/ui/TimelineEvents.tsx

Tapping a timeline entry's time, read as "Edit date and time for ‹title›, currently ‹time›", opens "Edit date and time" with the entry's title and its current date and time.

### EVT-069: Changing date and time needs a change
Status: draft
Migration: same
Source: src/modules/pet-events/forms/usePetEventDateTimeForm.ts

"Save date and time" stays disabled until the date or time differs, and while it's invalid.

### EVT-070: A new date and time re-orders the timeline
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

A saved date and time closes the sheet and moves the Pet event to its new place in the timeline, Today and the current diet.

### EVT-071: A failed date and time change keeps the old time
Status: draft
Migration: same
Source: src/modules/pet-events/forms/usePetEventDateTimeForm.ts

A failed date and time save keeps the sheet open with the new values and the Pet event at its old time.
Note: possible bug, confirm: the reference shows no message, so nothing says the save failed.

### EVT-072: Re-dating a Diet change replays the current diet
Status: draft
Migration: same
Source: src/modules/pet-events/model/getCurrentDiet.ts

The current diet follows a Diet change's new date and time.
Note: possible bug, confirm: a stop or switch dated before the item was added leaves the item in the current diet.

### EVT-073: A Pet event is deleted after confirming
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DeletePetEventModal.tsx

The trash button on a timeline entry and "Delete event" on the detail ask "Delete this event?" with "This will permanently remove it from ‹name›'s timeline.", the entry's title and time, Cancel and Delete.

### EVT-074: The delete button is read with the entry
Status: draft
Migration: same
Source: src/modules/pet-events/ui/TimelineEvents.tsx

VoiceOver reads a timeline entry's trash button as "Delete timeline event: ‹title›, ‹time›".

### EVT-075: A confirmed delete removes the Pet event at once
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventsProvider.tsx

Delete removes the Pet event for the whole Household and from the timeline, Today and the current diet straight away.

### EVT-076: Deleting shows progress and can't be cancelled
Status: draft
Migration: same
Source: src/modules/pet-events/ui/DeletePetEventModal.tsx

While a delete runs, Delete reads "Deleting…" and the confirmation can't be cancelled or dismissed.

### EVT-077: A failed delete keeps the Pet event
Status: draft
Migration: same
Source: src/modules/pet-events/state/PetEventFormsProvider.tsx

A failed delete keeps the Pet event and the confirmation open with "This event could not be deleted. It is still saved. Please try again."

### EVT-078: A Pet event already gone deletes without error
Status: draft
Migration: same
Source: src/modules/pet-events/persistence/petEventStore.ts

Deleting a Pet event another Member already deleted succeeds and removes it from the list.

### EVT-079: One change at a time on the timeline
Status: draft
Migration: same
Source: src/modules/pet-events/ui/TimelineEvents.tsx

While a Pet event is being deleted or re-dated, every timeline entry's trash button and time are disabled.

### EVT-080: A Pet's Pet events go with the Pet
Status: draft
Migration: same
Source: supabase/migrations/20261107170053_per_pet_ownership.sql

Deleting a Pet deletes all its Pet events.

### EVT-081: Members manage their Household's Pet events
Status: draft
Migration: same
Source: supabase/migrations/20261108101114_household_pets.sql

A Member can read, log, edit and delete Pet events of their Household's Pets, and can't move one to a Pet outside it.

### EVT-082: Outsiders can't reach a Household's Pet events
Status: draft
Migration: same
Source: supabase/migrations/20261108101114_household_pets.sql

A Member of another Household can't read, log, edit or delete a Household's Pet events.

### EVT-083: Signed-out people can't reach any Pet event
Status: draft
Migration: same
Source: supabase/migrations/20261108101114_household_pets.sql

A signed-out person can't read, log, edit or delete any Pet event.
