# What Linear holds that GitHub and the repo don't

Research for [#10](https://github.com/PatyCu/kiwi-tracker-swift/issues/10) (map [#3](https://github.com/PatyCu/kiwi-tracker-swift/issues/3)), read on 2026-11-28.

**Sources.** Linear project *Kiwi Tracker* (P-KIW-1), read only through the Linear MCP list/get tools: all 106 issues (KIW-5…KIW-110, none archived), every issue's comments, the project's description, milestones and documents. Expo code at `.reference/kiwi-tracker` (commit `c6db92f`, the commit the Linear project says it was last synced at). Repo docs on `main` at `784c2c0`.

**Headline facts.**

- No Linear issue has a comment, and the project has no documents, resources or project comments. Everything Linear holds is in issue titles, descriptions, labels, statuses, parents, milestones and five embedded images.
- 60 issues are Done (7 of them bugs, `Bug` label), 1 Canceled, 16 Todo, 29 Backlog.
- 20 Done issues (KIW-73…KIW-92) are sub-issues of KIW-9 and KIW-45 with empty descriptions: their titles are the only content.
- Paths below are relative to `.reference/kiwi-tracker/src` unless they start with `docs/`, `ios/` or `supabase/`.

## 1. Done features

"In code" means the description's behaviour is in the Expo code. "Linear only" lists a decision or rule stated in Linear that is in neither the Expo code nor this repo's docs; "—" means none.

| KIW | Title | In code | Linear only |
|---|---|---|---|
| 9 | Store pets and events in Supabase | Yes (`*/persistence/*Store.ts`) | On-device AsyncStorage data was deliberately not imported (moot for iOS). The schema artifact link is already in `AGENTS.md`. |
| 11 | Upcoming care (next 7 days) | Yes (`modules/calendar/upcomingCare.ts`, `UpcomingCareList.tsx`) | — |
| 20 | Up next: add calendar event | Yes (`modules/calendar-events/`) | No repeating events and no guests, "for now" (intent; the code just lacks them). Google Calendar as the design reference, with a screenshot. |
| 22 | Multi-pet support | Yes | Superseded line ("starts with a default pet named Kiwi") replaced by KIW-84; nothing to keep. |
| 23 | Add a pet and edit its profile | Yes | — |
| 24 | Pet photo from the photo library | Yes | — |
| 25 | Pet selector cards with editing built in | Yes | — |
| 26 | Pet overview page | Yes (`modules/pets/ui/PetOverview.tsx`: Calendar and Profile links) | — |
| 27 | Log a symptom | Yes (`modules/pet-events/model/PetEvent.ts`) | — |
| 28 | Log a diet change | Yes (`DIET_ITEM_TYPES`) | — |
| 29 | Log another event | Yes | — |
| 30 | Quick Log | Yes (`TodayQuickLogCard.tsx`, `PetActivityCard.tsx`) | — |
| 31 | Date and time pickers | Yes (`DateTimePickerField.web.tsx` is the web version) | — |
| 32 | Current diet worked out from diet history | Yes (`getCurrentDiet.ts`) | — |
| 33 | Edit an event | Yes (`applyPetEventEdit.ts` renames the item across history) | "Which item was replaced or stopped can't be changed" is stated as a rule only here; the code enforces it by not offering it. |
| 34 | Per-pet and all-pets timelines | Partly: the all-pets Timeline tab is gone (replaced by KIW-102); the pet page keeps "Recent timeline" | — |
| 35 | Event detail screen | Yes (`PetEventDetailScreen.tsx`) | — |
| 36 | Change an event's date and time | Yes (`EditPetEventDateTimeModal.tsx`) | — |
| 37 | Delete an event | Yes, with confirmation (`DeletePetEventModal.tsx`) | — |
| 38 | Green, amber and red status per pet | Yes (`calculatePetStatus.ts`: 3- and 7-day windows) | — |
| 39 | Today summary across all pets | Yes (`buildTodayViewModel.ts` sorts by severity) | — |
| 40 | Responsive tab navigation | Yes (`PrimaryNavigation.tsx`) | — |
| 41 | Appearance setting | Yes | — |
| 42 | On-device storage | Yes | Device keeps only the Session, the Appearance choice and, on iOS, cached photos. Matches ADR 0004; nothing new. |
| 43 | Accessible modal sheets | Yes (`useModalAccessibility.ts`) | — |
| 44 | Typecheck, lint, format and Jest tests | Yes (Expo tooling) | — |
| 45 | Pets belong to a household | Yes | "Invites in Free v1 automate" household setup: roadmap intent, see KIW-52. |
| 46 | Sign in with email and password | Yes (`supabase/config.toml`: `enable_signup = false`) | — |
| 84 | New accounts start with no pets | Yes (`NoPetsCard.tsx`) | — |
| 88 | Household alias on Today, Pets and Settings | Yes | — |
| 89 | No-household setup screen | Yes (`NoHouseholdScreen.tsx`) | — |
| 91 | Members by display name in Settings | Yes | — |
| 98 | Show or hide the password | Yes | — |
| 102 | Calendar tab replaces Timeline | Yes (`modules/calendar/`) | Web month grid "like Google Calendar"; phone month with the selected day's list. Two reference screenshots live only in Linear. |
| 108 | Open a calendar event's details | Yes (`CalendarEventDetailsModal.tsx`; 9:00 default in `useCalendarEventForm.ts`) | Details are read-only and "editing and deleting come later": intent, no issue for it. |
| 109 | Calendar tab UX improvements | Yes (`CalendarFilter.tsx`, `MonthGrid.tsx`) | — |
| 110 | Calendar tab mobile UX tweaks | Yes (`CompactMonth.tsx`, `CalendarToolbar.tsx`) | — |

Sub-issues with title only, all Done and all in the code or `supabase/` (no extra decision): KIW-73…KIW-86 (children of KIW-9) and KIW-87…KIW-92 (children of KIW-45). Two titles record decisions that the code and the migrations hold already: KIW-81 (`recordedAt` became `createdAt`; `activePetId` and the pet's `createdAt` dropped) and KIW-82 (event updates send only editable fields, `petEventStore.ts`). KIW-76 then KIW-79 record that households were replaced by per-pet ownership and then brought back; only the final state is in the migrations.

**Decisions found only in Linear (Done features):** 4: KIW-20 (no repeating events or guests, for now), KIW-33 (which item was replaced or stopped can't be edited), KIW-108 (details read-only; editing and deleting later) and KIW-9 (on-device data not imported). The KIW-20 and KIW-102 screenshots are design references, not rules. None changes parity behaviour. Only KIW-20's and KIW-108's "for now" items suggest future work, and no Linear issue covers them.

## 2. Done bugs

| KIW | Title | Regression it guards | Fix |
|---|---|---|---|
| 5 | Today tab had a quick-add + button in the top-right corner | Today has no header "+" button; adding goes through Quick Log and the cards | 2026-08-02 (imported from the Expo repo's GitHub issue #2) |
| 6 | Today header showed the page name instead of the app name and logo | Today's header shows the app name and logo (`AppHeader.tsx`), not "Today" | 2026-08-02 (Expo GitHub issue #3) |
| 7 | Today card logged a duplicate-key error when two status lines matched | Two identical status lines (two diet changes on one day) both show, with no key clash (`TodayCard.tsx` keys by index) | `655010d` |
| 99 | Timeline's empty state pointed to an add button the Timeline doesn't have | An empty-state hint only points to add buttons that exist on that screen | `7196484` |
| 100 | Pets tab showed an empty timeline while events were still loading | The Pets tab waits for events as well as pets before showing an overview, so it never shows an empty, calm Pet by mistake | `4fdc4f3` |
| 104 | On web, screen readers don't hear which tab, pet or option is selected | Web only: selected and checked states reach screen readers as `aria-selected`/`aria-checked` (plan Phase 8 already lists it) | `989e8ba` |
| 105 | "Page not found" link is unreadable in dark mode | The not-found screen's "Return to Today" link uses the theme's text colour (`+not-found.tsx`) | `989e8ba` |

KIW-104 is the only Bug-labelled issue beyond the six named in #10; it is web-only and already in Phase 8 of the plan.

## 3. Todo, Backlog and Canceled

"Keep" means it becomes an `after-parity` GitHub issue; "dup-of" means fold it into the named issue. These are suggestions for [#18](https://github.com/PatyCu/kiwi-tracker-swift/issues/18) to decide.

| KIW | Status | Title | Gist | Parent | Suggest | Reason |
|---|---|---|---|---|---|---|
| 8 | Backlog | UI component naming guide standardization | Naming guide for UI components, with renames | — | drop | It's about the Expo code; the iOS side has `ios/CONVENTIONS.md` and the done "Consistent UI names" feature |
| 10 | Canceled | Care tracking | Separate Care section dropped, "no clear value"; placeholder tab removed | — | drop | Already canceled; nothing in code |
| 12 | Todo | Replace "overdue care" with "Reminders for today" | Today's Overdue placeholder card becomes "Reminders for today", copy only | — | dup-of 106 | Part of one Reminders issue; changes parity behaviour (Overdue exists in `TodayScreen.tsx`) |
| 13 | Todo | Empty states on every screen | Check every screen has an empty state | — | drop | Each area's requirements now state its empty states; the parity sign-off checks the rest |
| 14 | Todo | Confirm before destructive actions | Event delete already confirms; pet delete will need it | — | dup-of 16 | The only part left is pet deletion |
| 15 | Todo | Household members can add, edit and delete pets and events | Any member manages all pets and events | — | drop | Done by KIW-87's RLS (PET-033, PHOTO-026); pet delete is KIW-16 |
| 16 | Todo | Delete a pet | Not built; needs a confirmation step | — | keep | Real missing capability; set it against archiving (KIW-57) when decided |
| 17 | Todo | Log medication and treatments | New Pet event type; should count in the health status rules | — | keep | Distinct from scheduled meds (Calendar events); carries a health-status rule to decide |
| 18 | Todo | Log environment events | House move, new pet, cleaning products, weather | — | keep | New Pet event type |
| 19 | Backlog | Edit an event in a modal on web | Web editing as a modal, not a page | — | drop | The React web app is a rebuild (Phase 8); decide its layout there |
| 21 | Backlog | Release to TestFlight and the web | TestFlight internal testing, no public App Store listing; web as a static export | — | drop | Already plan lines in Phases 7 and 8 (moving to milestones in #19). Carry "internal testing only, no public listing" into that milestone |
| 47 | Backlog | Today with no pets: show the add-pet form | Add-pet form on Today instead of the No pets yet card; other tabs disabled | — | keep | UX change; the map's Fog says it becomes a `prototype` ticket |
| 48 | Backlog | Settings: household members in one row | Members as icons with names, side by side | — | keep | UX; prototype ticket per map Fog |
| 49 | Backlog | Settings: appearance as a polished toggle | Better System/Light/Dark control | — | keep | UX; prototype ticket per map Fog |
| 50 | Backlog | Sign up and get your own household | In-app sign-up creates an Account and its Household in one step | — | keep | Coherent feature; KIW-93/94/95 become its tickets. Contradicts GLOSSARY ("never in the app") until decided |
| 51 | Backlog | Join an existing household when signing up | New account joins an existing Household | — | dup-of 52 | Joining is accepting an invite |
| 52 | Backlog | Send and accept invites to a household | Member invites; accepting adds to the Household | — | keep | Needed once sign-up exists |
| 53 | Todo | Export for vet | Disabled "Coming soon" label on the pet activity card | — | keep | The disabled label is parity behaviour (`PetActivityCard.tsx`); the export itself is after parity |
| 54 | Backlog | Manage household | Member list, rename the Household, remove people | — | keep | Pairs with sign-up and invites; KIW-96/97 fold in |
| 55 | Backlog | Change your password in Settings and recover a forgotten one | Until then passwords are set and reset in the Supabase dashboard; recovery needs email sending on the shared project | — | keep | Real gap; its constraint (email sending) is only in Linear |
| 56 | Backlog | Show who logged an event | (no description) | — | keep | Small, uses Members' Display names |
| 57 | Backlog | Archive a pet | (no description) | — | keep | Folds KIW-58/59/60 into one "Archive and restore a Pet" issue |
| 58 | Backlog | View archived pets | (no description) | — | dup-of 57 | Same feature |
| 59 | Backlog | View an archived pet's history | (no description) | — | dup-of 57 | Same feature |
| 60 | Backlog | Restore an archived pet | (no description) | — | dup-of 57 | Same feature |
| 61 | Backlog | Take a pet photo with the camera | Camera permission is off in `app.json` | — | keep | Small on iOS (PHOTO-002 says library only today) |
| 62 | Backlog | More profile fields | Weight, sex, neutered, microchip, vet contact, allergies | — | keep | Schema and UI change |
| 63 | Backlog | More event types | Vet visits, vaccines, weight | — | drop | Vet visits and vaccines are Calendar events since KIW-20; weight belongs in KIW-62 |
| 64 | Backlog | Symptom severity | (no description) | — | keep | Could feed the health status rules |
| 65 | Todo | Filter or search the timeline | By pet, type or date range; Calendar already filters by pet and type | — | keep | Narrowed to search and date ranges |
| 66 | Backlog | Reminders and notifications | Premium care reminders and notifications (medicine, vaccines, deworming); design image | — | keep | Notifications, separate from the Reminders tab (KIW-106); download its design image before archiving |
| 67 | Backlog | Trends and charts | Symptom frequency and links to diet changes | — | keep | Product idea with a stated scope |
| 68 | Backlog | Android check | `app.json` has Android icons; no docs or checks | — | drop | The native rebuild is iOS and web only (ADR 0001) |
| 69 | Backlog | More settings | Units, data management, About | — | drop | Vague; open a specific issue when one is decided |
| 70 | Backlog | Encrypt the sign-in session on iOS | Move the session from AsyncStorage to secure storage before a public release | — | drop | Done on iOS: `ios/KiwiKit/Sources/KiwiData/KeychainSessionStorage.swift` |
| 71 | Backlog | Work offline and sync when back online | Device copy, queued changes, conflicts, sync status | — | drop | ADR 0004 decides online-only; a new ADR would reopen it |
| 72 | Backlog | Household guests with access to chosen pets | Pet sitter sees chosen Pets, maybe read-only, in several Households | — | keep | Changes the access model (ADR 0003); worth keeping as an idea |
| 93 | Todo | Sign up from the app | (no description) | 50 | dup-of 50 | Ticket of KIW-50 |
| 94 | Todo | Create the household and membership in the same transaction as the account (trigger on auth.users) | (title only) | 50 | dup-of 50 | Ticket of KIW-50; the trigger design is only in this title |
| 95 | Todo | Database test: every new account gets a household and a membership | (title only) | 50 | dup-of 50 | Ticket of KIW-50 |
| 96 | Todo | See and manage household members, and rename the household | (no description) | 54 | dup-of 54 | Ticket of KIW-54 |
| 97 | Todo | Remove someone from the household | (no description) | 54 | dup-of 54 | Ticket of KIW-54 |
| 101 | Backlog | Photos on events | Attach photos (stool or vomit sample, medicine) to any event | — | keep | Premium v1 idea with a clear use |
| 103 | Backlog | Export or share the calendar | Export or share button on the Calendar tab | — | keep | Premium v1; distinct from KIW-53 (vet export) |
| 106 | Todo | New tab / section Reminders with empty state page | Reminders tab after Pets, before Calendar; iOS-Reminders-like icon; "No reminders yet" and a green floating "+" | — | keep | One Reminders issue, folding KIW-12 and KIW-107 |
| 107 | Todo | Add a Reminder modal / popup | UI only, from a design image | — | dup-of 106 | Same Reminders feature; download its design image before archiving |

**Counts (46 issues):** 23 keep, 11 drop, 12 dup-of.

| Suggestion | KIW |
|---|---|
| keep (23) | 16, 17, 18, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 61, 62, 64, 65, 66, 67, 72, 101, 103, 106 |
| drop (11) | 8, 10, 13, 15, 19, 21, 63, 68, 69, 70, 71 |
| dup-of (12) | 12, 14, 51, 58, 59, 60, 93, 94, 95, 96, 97, 107 |

## 4. Project-level content

| Where | Content | In the repo? |
|---|---|---|
| Project description | "The only roadmap and bug list for Kiwi Tracker. Milestones are the phases, in order; features with no milestone are Unplanned. Bugs carry the Bug label and Urgent priority. Last synced at commit c6db92f." | Sync commit matches the reference pin. The "bugs are Urgent" rule is replaced by `docs/agents/issue-tracker.md` (bugs come before the next ticket) |
| Milestones | MVP - Foundation (86%), Engineering Roadmap ("keeps the codebase consistent and maintainable"), MVP - UX Improvements ("added by the developer as they come up"), MVP - Reminders, MVP - Free features, Premium v1, Premium v2 | **No.** The free-versus-premium product tiering (which features are Free, Premium v1 or Premium v2) exists only here. It's the one product-level decision to carry over, for example as a line in each kept issue or a label |
| Documents, resources, project comments | None | — |
| Embedded images | KIW-20 (calendar event form), KIW-102 (two calendar screenshots), KIW-66 and KIW-107 (reminder design, "Add care, pick a type") | **No.** Download those in KIW-66 and KIW-107 into their GitHub issues before Linear is archived. KIW-20's and KIW-102's are superseded by the built Expo screens |

Milestone of each kept issue, for carrying the tiering over: Free features: 50, 52, 54, 55. Reminders: 106 (with 12, 107). UX Improvements: 47, 48, 49. Premium v1: 53, 56, 66, 101, 103. Premium v2: 57. MVP - Foundation: 16, 17, 18. No milestone: 61, 62, 64, 65, 67, 72.

## 5. KIW-n references in this repo

From `grep -rn "KIW-" --exclude-dir=.reference .` on `784c2c0` (with `.git` left out). 13 commit messages also cite KIW-n; those stay as history.

| File | Line | Reference |
|---|---|---|
| `docs/agents/issue-tracker.md` | 3 | "`KIW-n` names the reference feature in Linear being ported" |
| `docs/agents/issue-tracker.md` | 8 | Example plan line "Pet overview screen (KIW-26)" |
| `docs/migration-plan.md` | 14 | "`KIW-n` is the reference feature in Linear being ported" |
| `docs/migration-plan.md` | 37 | Phase 0: "Linear's Kiwi Tracker project stays the read-only reference (`KIW-n`)" |
| `docs/migration-plan.md` | 58–64 | Phase 2: KIW-46, 98, 89, 88, 91, 41 |
| `docs/migration-plan.md` | 70–77 | Phase 3: KIW-22, 84, 23, 25, 24, 26 |
| `docs/migration-plan.md` | 83–93 | Phase 4: KIW-27, 28, 29, 30, 31, 32, 34, 35, 33, 36, 37 |
| `docs/migration-plan.md` | 99–100 | Phase 5: KIW-38, 39 |
| `docs/migration-plan.md` | 106–111 | Phase 6: KIW-102, 20, 108, 109, 110, 11 |
| `docs/migration-plan.md` | 119–120 | Phase 7: KIW-5, 6, 7, 99, 100, 105; KIW-21 |
| `docs/migration-plan.md` | 130–131 | Phase 8: KIW-104; KIW-21 |
| `ios/KiwiKit/Sources/KiwiFeatures/Pets/UI/PetsScreen.swift` | 75 | Comment "The overview replaces this with KIW-26." |

Linear is also named without a KIW-n in `CONTRIBUTING.md:27` ("Don't use GitHub Projects or Linear"). `docs/requirements/` cites no KIW-n.
