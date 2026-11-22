# Pets list and multi-pet support (KIW-22)

Status: done

## Problem Statement

The iOS Pets tab is a placeholder. In the reference app, a Household's Members see all of its Pets as a row of selector cards on the Pets tab, and choose the one they want to manage.

## Solution

The app loads the signed-in Account's Pets at sign-in. The Pets tab shows "Choose the pet you want to manage." above a horizontal row of selector cards, one per Pet sorted by name: a paw avatar, the name, and a checkmark on the selected card. The first Pet is selected by default, and tapping a card selects it without pushing a screen. Below the cards, a placeholder card holds the place for the overview. While the Pets load the tab shows loading, and when the load fails it shows the error with Retry.

## User Stories

1. As a Member, I want to see every Pet in my Household on the Pets tab, so that I can manage any of them.
2. As a Member, I want the Pets sorted by name, so that they're in the same order on every device.
3. As a Member, I want the first Pet selected when I open the tab, so that the tab always shows one Pet.
4. As a Member, I want to tap a card to select its Pet, without leaving the tab.
5. As a Member, I want the selected card marked with a checkmark and a kiwi border, so that I can see which Pet is selected.
6. As a Member whose Pets are loading, I want to see loading, so that I know the tab isn't empty.
7. As a Member whose Pets couldn't load, I want the error with Retry, so that I can try again.
8. As a person signing in as another Account, I want to see only that Account's Household's Pets, never the previous Account's.
9. As a Member using VoiceOver, I want each card read as the Pet's name, with ", selected pet" on the selected one.
10. As a Member using Dynamic Type, I want the cards' text to scale.

## Implementation Decisions

- **Glossary**: **Pet** added.
- **Scope**: this feature leaves out what later Phase 3 features add to the same screen: the no-pets card (KIW-84), the add card and the profile sheet (KIW-23), the cards' Edit link (KIW-25), photos (KIW-24) and the overview (KIW-26). A Household without Pets keeps the placeholder screen until KIW-84.
- **KiwiDomain**: `Pet` with an id, a name and a species (`PetSpecies`: Cat, Dog, Other). `PetStore.loadPets()` with the error cases `couldNotLoad` and `invalidData`.
- **KiwiData**: `SupabasePetStore` reads `id, name, species` from `pets`, ordered by name, then id. Access rules return only the Household's Pets. An unknown species fails the whole load with `invalidData`, as the reference does, rather than guessing.
- **State**: `PetsModel` with loading, ready and failed states, created per sign-in next to `HouseholdModel` in `AppRoot`, so a new Account never sees the previous Pets. Its load starts at sign-in, alongside the Household, as the reference's `PetsProvider` loads per user. Calling it again is Retry, and only the latest load counts. The Household's Retry and "Check again" reload the Pets too, so an Account just added to a Household sees its Pets.
- **Waiting**: the Pets tab waits for the Pets only. The reference also waits for events and calendar events, and Phases 4 and 6 add those loads when their data arrives.
- **Selection**: tab state, not a route: the selected Pet's id, defaulting to the first Pet and falling back to it when the selected Pet is gone. `Route` is unchanged; `Route.pet` stays the pushed overview.
- **Help line**: "pet" where the reference says "Choose the profile you want to manage.", since the glossary's term is Pet; confirmed by the developer.
- **Avatar**: a kiwi tint behind the paw, where the reference uses the card's surface color and the selected card hides it; confirmed by the developer.
- **Title**: the navigation title stays "Pets in {alias}" (KIW-88); the help line is the first row of the content.

## Testing Decisions

- **KiwiData**: the reference's `petStore` load cases, ported case for case: "loads the household's pets by name", "reports an unknown species instead of guessing", "wraps a failed load in a typed error", plus Supabase being unreachable. The write cases come with KIW-23 and KIW-24, and the photo-link cases with KIW-24.
- **KiwiFeatures**: `PetsModel` loads, fails, retries, shows loading again during a Retry, and ignores an earlier load that finishes last. The selection defaults to the first Pet and falls back when the selected Pet is gone.
- **Previews**: the Pets tab loaded with two Pets, loading and error, light and dark.
- **Simulator**: the local stack signed in as a shared-household Account (two Pets) and as Riley (no Pets), then the shared project.

## Out of Scope

- Everything listed under **Scope**.
- Waiting for events and calendar events.
