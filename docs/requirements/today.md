# Today

### TODAY-001: Today's sections come in a fixed order
Status: active
Migration: changed
Source: src/modules/today/ui/TodayScreen.tsx

With Pets, Today shows the summary card, then "Upcoming (next 7 days)" and "Add event".
Note: the reference also shows an "Overdue" placeholder section between them.

### TODAY-002: Without Pets, Today shows only the No pets yet card
Status: active
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

A Household without Pets sees on Today only its title and the No pets yet card, without Upcoming, Overdue or Add event.

### TODAY-003: Today's title without an alias
Status: active
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

When the Household has no alias, Today's title reads "Today" without Pets, and "Today with ‹Pet names›" with them.

### TODAY-004: Pet names in the title are joined in name order
Status: active
Migration: same
Source: src/modules/today/formatPetNames.ts

The Pet names in Today's title follow name order, joined as "Kiwi", "Kiwi and Luna" or "Kiwi, Luna and Miso".

### TODAY-005: One summary covers every Pet
Status: active
Migration: same
Source: src/modules/today/buildTodayViewModel.ts

Today shows a single summary card whose status is the highest among all the Household's Pets: red, then amber, then green.

### TODAY-006: The summary says the highest status's headline
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

The summary card's headline is the headline of its status.

### TODAY-007: A green summary says nothing to review
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

A green summary card reads "No recent symptoms or changes to review."

### TODAY-008: An amber or red summary points to the radar
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

An amber or red summary card reads "Recent activity needs to stay on your radar."

### TODAY-009: The summary indicator names the species or Pets
Status: active
Migration: same
Source: src/modules/today/buildTodayViewModel.ts

The summary's indicator is labelled with the Pet's species in capitals when there's one Pet, and "PETS" when there are several.

### TODAY-010: Every Pet has a row under the summary
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

Below the summary, every Pet has a row with its photo or avatar and its name.

### TODAY-011: A green Pet's row says all good
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

A green Pet's row reads "All good, nothing to see here."

### TODAY-012: An amber or red Pet's row lists its reasons
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

An amber or red Pet's row lists each of its status's reasons on its own line.

### TODAY-013: Rows put red first, then amber, then green
Status: active
Migration: same
Source: src/modules/today/buildTodayViewModel.ts

Pet rows are ordered red, then amber, then green, and Pets with the same status keep name order.

### TODAY-014: A row opens its Pet in Pets
Status: active
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

Tapping a Pet's row opens Pets with that Pet selected.

### TODAY-015: Rows are read with the Pet and its reasons
Status: active
Migration: same
Source: src/modules/today/ui/TodayCard.tsx

VoiceOver reads a Pet's row as "‹name›: ‹its lines›" with the hint "Opens ‹name› in Pets."

### TODAY-016: Today waits for Pet events and Calendar events
Status: active
Migration: same
Source: src/modules/calendar/useCalendarDataLoad.ts

Today shows loading, never the No pets yet card or a status, until the Pets, Pet events and Calendar events have all loaded.

### TODAY-017: A failed Today load offers Retry
Status: active
Migration: same
Source: src/shared/ui/LoadState.tsx

When the Pet events or Calendar events can't be loaded, Today shows "Could not load your data", "Check your connection and try again." and "Your saved data has not been changed." with Retry.

### TODAY-018: A failed load wins over one still loading
Status: active
Migration: same
Source: src/shared/state/LoadStatus.ts

When one load has failed while another is still running, Today shows the load error rather than loading.

### TODAY-019: Retry reloads only what failed
Status: active
Migration: same
Source: src/modules/calendar/useCalendarDataLoad.ts

Retry on Today reloads only the Pets, Pet events or Calendar events that failed, and keeps what already loaded.

### TODAY-020: Today follows logged events at once
Status: active
Migration: same
Source: src/modules/today/ui/TodayScreen.test.tsx

Logging, editing or deleting a Pet event updates Today's statuses straight away, without a reload.

### TODAY-021: Today moves on when the day changes
Status: active
Migration: changed
Source: src/modules/today/ui/TodayScreen.tsx

When the day changes while Today is open, or the app returns to the foreground on a new day, its statuses and days ago follow the new day without a reload.
Note: the reference only recomputes when the screen redraws, so an open Today can show yesterday's status.

### TODAY-022: Overdue is a placeholder
Status: dropped
Reason: Overdue belongs to reminders, a later phase out of parity scope.
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

The Overdue section always shows "No overdue items" and "Overdue care will appear here when calendar events are implemented."
Note: the copy says calendar events aren't implemented though they are; possible bug, confirm

### TODAY-023: Add event offers the three kinds of Pet event
Status: dropped
Reason: Duplicate of EVT-001.
Migration: same
Source: src/modules/today/ui/TodayQuickLogCard.tsx

The "Add event" section offers logging a Symptom, a Diet change or Other.

### TODAY-024: With one Pet, Add event logs for it
Status: dropped
Reason: Duplicate of EVT-004.
Migration: same
Source: src/modules/today/ui/TodayQuickLogCard.tsx

With one Pet, an event started from Today's Add event is for that Pet without asking.

### TODAY-025: With several Pets, Add event asks which Pet
Status: dropped
Reason: Duplicate of EVT-005.
Migration: same
Source: src/modules/today/ui/TodayQuickLogCard.tsx

With several Pets, an event started from Today's Add event asks which Pet it's for.
