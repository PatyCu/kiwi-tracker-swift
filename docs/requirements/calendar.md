# Calendar and Calendar events

### CAL-001: Calendar shows Pet events and Calendar events together
Status: active
Migration: same
Source: src/modules/calendar/calendarItems.ts

The Calendar tab shows the Household's Pet events, on the day they happened, and its Calendar events, on the day they start.

### CAL-002: Calendar opens on this month with today selected
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

Opening Calendar shows the current month with today selected and today's list below it.

### CAL-003: The month is titled with its name and year
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarToolbar.tsx

The month shown is titled with its full name and year, such as "November 2026", between a "‹" Previous month and a "›" Next month button.

### CAL-004: Weeks start on Monday
Status: active
Migration: same
Source: src/modules/calendar/monthGrid.ts

The compact month has a column per weekday headed Mon to Sun, Monday first.

### CAL-005: Only the month's own days are shown
Status: active
Migration: same
Source: src/modules/calendar/monthGrid.ts

Cells before the month's first day and after its last day are empty, and the month has as many weeks as it needs.

### CAL-006: February has its leap-year length
Status: active
Migration: same
Source: src/modules/calendar/monthGrid.ts

February shows 29 days in a leap year and 28 otherwise.

### CAL-007: The arrows move one month across years
Status: active
Migration: same
Source: src/modules/calendar/monthGrid.ts

Previous month from January shows December of the year before, and Next month from December shows January of the year after.

### CAL-008: Changing month selects today or the 1st
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

Moving to another month selects today when today is in it, and that month's 1st otherwise, even if no day was selected.

### CAL-009: Today is marked in the month
Status: active
Migration: same
Source: src/modules/calendar/ui/CompactMonth.tsx

Today's day number is ringed, and the selected day is filled, in whichever month shows them.

### CAL-010: Each day shows a dot per colour of what it has
Status: active
Migration: same
Source: src/modules/calendar/ui/CompactMonth.tsx

A day shows one dot for each distinct colour among its shown items: Symptom, Diet change, Other and Calendar event each have their own colour, and a day without items shows none.

### CAL-011: Day cells are read with their date and item count
Status: active
Migration: same
Source: src/modules/calendar/ui/CompactMonth.tsx

VoiceOver reads each day as its weekday, day and month, then the number of items it has ("1 item", "3 items") when it has any, with Selected on the selected day.

### CAL-012: Tapping a day selects it
Status: active
Migration: same
Source: src/modules/calendar/ui/CompactMonth.tsx

Tapping a day selects it and shows its list below the month.

### CAL-013: Tapping the selected day deselects it
Status: active
Migration: same
Source: src/modules/calendar/ui/CompactMonth.tsx

Tapping the selected day again leaves no day selected and hides the day's list.

### CAL-014: The day's list is headed with its date and the types shown
Status: active
Migration: same
Source: src/modules/calendar/ui/DayAgenda.tsx

The selected day's list is headed with its day and month, then "All events" when both event types are shown or the shown type's name ("Calendar events" or "Pet events").

### CAL-015: The day's list is earliest first
Status: active
Migration: same
Source: src/modules/calendar/calendarItems.ts

The selected day's Pet events and Calendar events are listed together by time, earliest first.

### CAL-016: Items fall on the device's local day
Status: active
Migration: same
Source: src/modules/calendar/calendarItems.ts

An Event shows on the day its time falls on in the device's time zone, so changing time zone can move it to another day.

### CAL-017: An empty day says so
Status: active
Migration: same
Source: src/modules/calendar/ui/DayAgenda.tsx

A selected day with nothing shown says "Nothing logged or scheduled on this day." when both event types are shown.

### CAL-018: An empty day under a type filter names the type
Status: active
Migration: same
Source: src/modules/calendar/ui/DayAgenda.tsx

A selected day with nothing shown under one event type says "No calendar events on this day." or "No pet events on this day."

### CAL-019: A Calendar event row shows its time range, title and place
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarItemRow.tsx

A Calendar event is listed with its start and end time ("09:00 – 10:00") in the device's format, its title, and its location when it has one.

### CAL-020: A Pet event row shows its time and title
Status: active
Migration: same
Source: src/modules/calendar/calendarItems.ts

A Pet event is listed with the time it happened and the same title and colour as in its Pet's activity.

### CAL-021: Rows name the Pet when several are shown
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

The day's rows name each item's Pet when more than one Pet is shown, and leave the name out when only one is.

### CAL-022: A Pet event opens inside the Calendar tab
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

Tapping a Pet event in the day's list opens its details in the Calendar tab, and going back returns to the Calendar.

### CAL-023: A Calendar event opens its details
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

Tapping a Calendar event in the day's list opens its details sheet over the Calendar.

### CAL-024: An Event whose Pet is gone is named Unknown pet
Status: active
Migration: same
Source: src/modules/calendar/calendarItems.ts

An Event whose Pet isn't in the Household's list is named "Unknown pet" wherever its Pet's name is shown.

### CAL-025: Every Pet and event type is shown at first
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

Calendar starts with every Pet and both event types shown, and every choice in "Filter by" checked.

### CAL-026: Filter by offers Pets and event types
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

"Filter by" opens a sheet with a PET section listing each Pet with its photo, and an EVENT TYPE section with "Calendar events" and "Pet events".

### CAL-027: A one-Pet Household gets no Pet filter
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

With a single Pet in the Household, "Filter by" offers only the event types.

### CAL-028: Filter choices apply as they are tapped
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

Unchecking a Pet or an event type hides its items from the month's dots and the day's list at once, and checking it shows them again.

### CAL-029: The last choice of a filter stays checked
Status: active
Migration: same
Source: src/modules/calendar/filterSelection.ts

Unchecking the only checked Pet, or the only checked event type, does nothing, so the Calendar never filters everything out.

### CAL-030: Filter by shows how many filters are on
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

While the Pets or the event types are narrowed, the "Filter by" button is highlighted with the number of narrowed filters (1 or 2).

### CAL-031: Filter by is read with what it narrows
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

VoiceOver reads the button as "Filter by", followed by the checked Pets' names and the checked event type for each filter that is on.

### CAL-032: Clear filters shows everything again
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

"Clear filters", shown only while a filter is on, checks every Pet and both event types again.

### CAL-033: Done closes Filter by
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarFilter.tsx

"Done" closes the "Filter by" sheet, keeping the choices made.

### CAL-034: A Pet's Calendar link shows only that Pet
Status: dropped
Reason: Duplicate of PET-039.
Migration: same
Source: src/modules/pets/ui/PetOverview.tsx

"Calendar" under More on a Pet's page opens the Calendar tab showing only that Pet's items, with the Pet filter on.

### CAL-035: A Pet filter for missing Pets shows every Pet
Status: active
Migration: same
Source: src/modules/calendar/petSelection.ts

When none of the Pets asked for is in the Household any more, the Calendar shows every Pet.

### CAL-036: Calendar waits for its data
Status: active
Migration: same
Source: src/modules/calendar/useCalendarDataLoad.ts

Calendar shows loading until the Pets, their Pet events and the Household's Calendar events have all loaded.

### CAL-037: A failed load on Calendar offers Retry
Status: active
Migration: same
Source: src/modules/calendar/useCalendarDataLoad.ts

When any of them can't be loaded, Calendar shows "Could not load your data" with Retry, and Retry loads again only what failed.

### CAL-038: Calendar says when there are no Pets
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

A Household without Pets sees, on Calendar, "No pets yet" and "Add a pet to see what you log and schedule for them by month."

### CAL-039: Today waits for the Calendar events
Status: dropped
Reason: Duplicate of TODAY-016 and TODAY-017.
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

Today shows loading until the Household's Calendar events have loaded, and the load error with Retry when they can't be.

### CAL-040: An invalid stored Calendar event fails the load
Status: dropped
Reason: The backend refuses a Calendar event that can't be read (CAL-073).
Migration: same
Source: src/modules/calendar-events/persistence/calendarEventStore.ts

A stored Calendar event that can't be read, such as one without a title, makes the whole Calendar events load fail.

### CAL-041: Each sign-in sees only its own Household's Calendar events
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventsProvider.tsx

After signing in as another Account, the app shows loading and then only that Account's Household's Calendar events, never the previous Account's.

### CAL-042: Calendar events load once per sign-in
Status: dropped
Reason: Not intended; seeing other Members' changes without signing in again is an after-parity issue.
Migration: same
Source: src/modules/calendar-events/state/CalendarEventsProvider.tsx

Calendar events added by another Member appear only after the next sign-in or a Retry, not while the app stays open.

### CAL-043: The + button adds a Calendar event on the selected day
Status: active
Migration: same
Source: src/modules/calendar/ui/AddCalendarEventButton.tsx

The "+" next to "Filter by" opens "Add calendar event" on the selected day, and VoiceOver reads it as "Add calendar event on" that day.

### CAL-044: With no day selected, + adds for today
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

With no day selected, the "+" is read as "Add calendar event" and opens the form for today.

### CAL-045: A new event today starts at the next full hour
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

A form opened for today starts at the next full hour and ends an hour later.

### CAL-046: A new event on another day starts at 9:00
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

A form opened for a day other than today starts at 09:00 and ends at 10:00.

### CAL-047: A late-evening new event moves to tomorrow
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

A form opened for today after 23:00 starts at 00:00 tomorrow, even when today is the selected day.

### CAL-048: A new event's end stays within its day
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

A suggested or shifted end time never passes 23:59 of the event's day.

### CAL-049: Moving the start keeps the length
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

Changing the start time moves the end time by the same amount, keeping the event's length, unless the end was not after the start.

### CAL-050: A Calendar event starts and ends on one date
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventModal.tsx

The form has one date with a start and an end time, so a Calendar event can't run past midnight.

### CAL-051: The form asks which Pet when it isn't known
Status: active
Migration: changed
Source: src/modules/calendar-events/state/CalendarEventFormsProvider.tsx

Opened from the Calendar in a Household with several Pets, the form shows a PET picker with the first Pet shown in the Calendar chosen.

### CAL-052: The only Pet is used without asking
Status: active
Migration: same
Source: src/modules/calendar/ui/CalendarScreen.tsx

In a Household with one Pet, the form adds for that Pet and shows no Pet picker.

### CAL-053: A Calendar event needs a title
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

"Save event" stays disabled while the title is empty or only spaces.

### CAL-054: Text fields have length limits
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventModal.tsx

The title takes at most 80 characters and the location at most 120; the description has no limit.

### CAL-055: The end must be after the start
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventModal.tsx

When the end time isn't after the start time, the form shows "End time must be after the start time." and "Save event" stays disabled.

### CAL-056: A start time that doesn't exist is refused
Status: active
Migration: same
Source: src/shared/dates/dateTime.ts

A start time skipped by a daylight-saving change on the chosen date shows "Choose a valid date and start time." and "Save event" stays disabled.

### CAL-057: Calendar events can be in the past
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

A Calendar event can be saved on any date, including before today.

### CAL-058: Values are saved trimmed, empty optional ones left out
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

The title, location and description are saved trimmed, and an empty location or description is saved as none.

### CAL-059: Times are saved in the device's time zone
Status: active
Migration: same
Source: src/shared/dates/dateTime.ts

The chosen date and times are read in the device's time zone, so the event is shown at the same moment on every device.

### CAL-060: Saving shows progress and can't be repeated
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventModal.tsx

While saving, the button reads "Saving…", the fields can't be edited, further taps save nothing and the form can't be closed.

### CAL-061: A saved Calendar event appears at once
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventsProvider.tsx

After saving, the form closes and the event appears in date order on the Calendar, Today and its Pet's Up next.

### CAL-062: A failed save keeps the form open with an alert
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventFormsProvider.tsx

When saving fails, the form stays open with its values and an alert says "Calendar event not saved" and "Your details are still in the form; please try again."

### CAL-063: An event saved while the list failed to load shows after Retry
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventsProvider.tsx

A Calendar event saved while the Calendar events load had failed is stored, and shows once Retry loads the list.

### CAL-064: Closing a changed form asks to discard
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventFormsProvider.tsx

Closing the form after changing any field asks "Discard this calendar event?" with "Your changes will not be saved.", offering "Keep editing" and "Discard".

### CAL-065: Closing an unchanged form doesn't ask
Status: active
Migration: same
Source: src/modules/calendar-events/state/CalendarEventFormsProvider.tsx

Closing the form with nothing changed closes it without asking.

### CAL-066: Each opening starts a fresh form
Status: active
Migration: same
Source: src/modules/calendar-events/forms/useCalendarEventForm.ts

Every time the form opens, its fields are empty and its times are suggested again, whatever was typed last time.

### CAL-067: The details sheet shows what was saved
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventDetailsModal.tsx

A Calendar event's details sheet is titled with its title and shows its Pet with their photo, its date with weekday and year, and its start and end times.

### CAL-068: Details show location and description only when set
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventDetailsModal.tsx

The details sheet shows LOCATION and DESCRIPTION only for an event that has them.

### CAL-069: Details leave out a Pet that's gone
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventDetailsModal.tsx

The details sheet of an event whose Pet isn't in the Household's list shows no PET section.

### CAL-070: Calendar events can't be edited or deleted
Status: active
Migration: same
Source: src/modules/calendar-events/ui/CalendarEventDetailsModal.tsx

The details sheet is read-only, and no screen edits or deletes a Calendar event.

### CAL-071: Members add and read their Household's Calendar events
Status: active
Migration: same
Source: supabase/migrations/20261112182254_calendar_events.sql

A Member can read and add Calendar events for their Household's Pets.

### CAL-072: Outsiders can't reach a Household's Calendar events
Status: active
Migration: same
Source: supabase/migrations/20261112182254_calendar_events.sql

A Member of another Household can't read or add Calendar events for a Household's Pets, and a signed-out person can't reach any.

### CAL-073: Stored Calendar events need a title and an end after the start
Status: active
Migration: same
Source: supabase/migrations/20261112182254_calendar_events.sql

The backend refuses a Calendar event with a blank title or an end not after its start.

### CAL-074: Deleting a Pet deletes its Calendar events
Status: active
Migration: same
Source: supabase/migrations/20261112182254_calendar_events.sql

When a Pet is deleted, its Calendar events are deleted with it.

### CAL-075: Upcoming Calendar events cover the next 7 days, today included
Status: active
Migration: same
Source: src/modules/calendar/upcomingCare.ts

Upcoming Calendar events are those that start before the end of the 7th local day counting today as the first.

### CAL-076: An event under way stays upcoming and an ended one leaves
Status: active
Migration: same
Source: src/modules/calendar/upcomingCare.ts

An event that has started but not ended stays upcoming, and one that has ended is no longer upcoming.

### CAL-077: Upcoming Calendar events are soonest first
Status: active
Migration: same
Source: src/modules/calendar/upcomingCare.ts

Upcoming Calendar events are sorted by start time, soonest first.

### CAL-078: Upcoming lists no Pet events
Status: active
Migration: same
Source: src/modules/calendar/upcomingCare.ts

Upcoming Calendar events never include Pet events.

### CAL-079: Upcoming rows name the day
Status: active
Migration: same
Source: src/shared/dates/dateTime.ts

Each upcoming row starts with "Today", "Tomorrow" or a short weekday and date ("Mon 16 Nov"), then the start and end times.

### CAL-080: Today shows the Household's upcoming Calendar events
Status: active
Migration: same
Source: src/modules/today/ui/TodayScreen.tsx

Today has an "Upcoming (next 7 days)" section with every Pet's upcoming Calendar events, naming the Pet on each row when the Household has more than one.

### CAL-081: Today's Upcoming says when nothing is scheduled
Status: active
Migration: same
Source: src/modules/calendar/ui/UpcomingCareList.tsx

With nothing upcoming, Today says "Nothing scheduled in the next 7 days" and "Scheduled vet visits, vaccines and medicines will show here."

### CAL-082: A Pet's Up next shows its upcoming Calendar events
Status: active
Migration: same
Source: src/modules/pets/ui/PetOverview.tsx

A Pet's page has an "Up next" section with only that Pet's upcoming Calendar events, without the Pet's name on the rows.

### CAL-083: Up next says when nothing is scheduled for the Pet
Status: active
Migration: same
Source: src/modules/calendar/ui/UpcomingCareList.tsx

With nothing upcoming for the Pet, Up next says "Nothing scheduled for" the Pet's name "in the next 7 days" and "Scheduled vet visits, vaccines and medicines will show here."

### CAL-084: Up next schedules for its Pet
Status: active
Migration: same
Source: src/modules/calendar/ui/scheduleAction.ts

"+ Schedule" on Up next, read as "Schedule calendar event", opens the form for today for that Pet without a Pet picker.

### CAL-085: Upcoming rows open their details
Status: active
Migration: same
Source: src/modules/calendar/ui/UpcomingCareList.tsx

Tapping an upcoming row on Today or Up next opens that Calendar event's details sheet.
