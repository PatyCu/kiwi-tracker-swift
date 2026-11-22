# No pets yet card on Today and Pets (KIW-84)

Status: ready-for-agent

## Problem Statement

A Member whose Household has no Pets sees placeholder screens on Today and Pets that say nothing about why they're empty. In the reference app, both tabs show a "No pets yet" card in place of their content, saying what adding a Pet unlocks on that tab.

## Solution

When the Household's Pets have loaded and there are none, Today and Pets each show a card under their usual title: a paw icon, "No pets yet" and the tab's own description. Today now waits for the Pets as the Pets tab does, with loading and the error with Retry. A Household with Pets sees Pets as before and Today's placeholder. The card's "Add your first pet" button arrives with the add-pet sheet in KIW-23.

## User Stories

1. As a Member of a Household without Pets, I want the Pets tab to say "No pets yet", so that I know the tab is empty because there are no Pets, not because something broke.
2. As a Member of a Household without Pets, I want Today to say "No pets yet", so that the first tab I see explains itself.
3. As a Member, I want the Pets tab's card to say "Add a pet to keep their profile, photo and health history together.", so that I know what the tab is for.
4. As a Member, I want Today's card to say "Add a pet to see how they're doing today and log what happens.", so that I know what Today will show.
5. As a Member, I want the card under the tab's usual title ("Today in {alias}", "Pets in {alias}"), so that I still see which Household I'm in.
6. As a Member, I want Today to show loading while the Pets load, so that it never flashes "No pets yet" before they arrive.
7. As a Member whose Pets couldn't load, I want Today to show the error with Retry, so that I can try again from Today.
8. As a Member who taps Retry on Today, I want the Pets loaded again, and the Pets tab to update too, since both tabs share one load.
9. As a Member of a Household with Pets, I want Today to keep its placeholder, so that the card only appears when there really are no Pets.
10. As a Member of a Household with Pets, I want the Pets tab unchanged: the selector cards and the overview placeholder.
11. As a Member just added to a Household with Pets, I want "Check again" or Retry to replace the card with the Pets, as the Pets load already does.
12. As a person signing in as another Account, I want the card shown or hidden by that Account's Household, never the previous one's.
13. As a Member using VoiceOver, I want "No pets yet" read as a heading and the icon skipped, so that I hear only what matters.
14. As a Member using Dynamic Type, I want the card's text to scale and wrap.
15. As a Member in light or dark appearance, I want the card in the app's palette.

## Implementation Decisions

- **Glossary**: no change; the copy already uses "pet".
- **Card**: `NoPetsCard` in the Pets feature, taking the description, since each tab says what adding a Pet unlocks there. Centered paw icon in a tinted tile, "No pets yet" as a heading, the description in the muted color, on a bordered surface card, from the reference's `NoPetsCard`. The icon is hidden from VoiceOver.
- **Button**: left out until KIW-23, which adds "Add your first pet" with its sheet; confirmed by the developer. No disabled or inert button.
- **Pets tab**: the card replaces the placeholder screen in the ready state with no Pets, under the navigation title "Pets in {alias}".
- **Today**: a `TodayScreen` takes Today's placeholder's place in the tab, given the Household and the `PetsModel` loaded since sign-in, as the Pets tab is. It shows loading and the error with Retry from the model's states, the card when the Pets are none, and the existing placeholder otherwise, all under "Today in {alias}". Retry reloads the shared `PetsModel`.
- **Waiting**: Today waits for the Pets only. The reference also waits for events and calendar events; Phases 4 and 6 add those loads.
- **Copy**: word for word from the reference; confirmed by the developer.

## Testing Decisions

- **Unit tests**: none new. The reference's empty-state cases ("adds the first pet from the empty state when the household has none yet") need the add-pet sheet and come with KIW-23; "shows a loading state, not the empty state, until pets and events have loaded" also waits on events and comes with Phase 4. The Pets load, failure and Retry are covered by `PetsModelTests`; confirmed by the developer.
- **Previews**: the Pets tab's existing "No pets" previews show the card. `TodayScreen` gets loaded, no pets, loading and error previews, light and dark, per `ios/CONVENTIONS.md`.
- **Simulator**: the local stack signed in as Riley (no Pets) and as a shared-household Account (two Pets), on Today and Pets; then the shared project.

## Out of Scope

- The "Add your first pet" button and the add-pet sheet (KIW-23).
- The card on Calendar, with "Add a pet to see what you log and schedule for them by month.", which comes with the Calendar screen.
- Today's content for a Household with Pets.
- Waiting for events and calendar events.
