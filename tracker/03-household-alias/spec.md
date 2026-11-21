# Household alias on Today, Pets and Settings (KIW-88)

Status: done

## Problem Statement

Members can't see which Household they're in. Once the Household loads, Today, Pets and Settings show generic titles and no Household at all, while the reference app names it: "Today in The Burrow", "Pets in The Burrow" and a Household section in Settings.

## Solution

Once the Household has loaded, Today's title reads "Today in ‹alias›" and Pets' title reads "Pets in ‹alias›", as navigation large titles. Settings gains a Household section, above Account, with an **Alias** row showing the Household alias. The alias is shown without spaces at either end.

## User Stories

1. As a Member, I want Today's title to name my Household, so that I know whose pets I'm looking at.
2. As a Member, I want Pets' title to name my Household, so that the list is clearly our shared pets.
3. As a Member, I want the Household's name in the navigation bar's large title, so that it looks and behaves like any iOS app.
4. As a Member, I want the tab labels to stay "Today" and "Pets", so that the tab bar stays short and familiar.
5. As a Member with a long Household alias, I want the title shortened with "…" rather than wrapped or overlapping, so that the screen stays readable.
6. As a Member, I want Settings to show a Household section, so that I can check which Household my Account belongs to.
7. As a Member, I want the Household section to sit above Account, so that Settings has the reference's order (Appearance, then Household, then Account, as those features arrive).
8. As a Member, I want the row labelled "Alias", so that the app uses the same word for the Household alias everywhere.
9. As a Member whose Household alias was set with stray spaces, I want them gone, so that titles and Settings look clean.
10. As a Member, I want the alias to show as soon as the tabs open, so that I never see a title without my Household.
11. As a Member using Dynamic Type, I want the titles and the Alias row to scale with my text size, so that I can read them.
12. As a Member using VoiceOver, I want the titles and the Alias row read as plain text ("Today in The Burrow"; "Alias, The Burrow"), so that I hear the same information.
13. As a Member in dark mode, I want the Household section styled with the palette like the rest of Settings, so that it matches the app.
14. As a developer, I want the title copy to come from small tested functions, so that the later Today and Pets screens reuse the same rule instead of retyping it.

## Implementation Decisions

- **Domain**: `Household` trims spaces and newlines from both ends of its alias when it's created, so every source and screen gets the trimmed alias. The schema rejects aliases that are only spaces; one made only of other whitespace, such as newlines, would trim to empty, which is accepted as too unlikely to guard against. No schema change.
- **Titles**: `KiwiFeatures` gets two copy functions taking the `Household`: one for "Today in ‹alias›", one for "Pets in ‹alias›". The current Today and Pets screens (still placeholders) use them as their navigation titles. Tab labels don't change.
- **No fallback titles**: the reference falls back to "Today" and "Your pets" while the Household hasn't loaded. On iOS the tabs only open after the Household has loaded, so the functions take a `Household` that's always there and have no fallback.
- **Settings**: a native `Form` section titled "Household", placed above Account, with one labelled row "Alias" showing the alias, read from the Household in the environment. Members (KIW-91) and Appearance (KIW-41) come later.
- **Copy**: "Alias" replaces the reference's "Name", following the parity rule's exception: copy naming a domain concept uses its `GLOSSARY.md` term. That exception is already in the agent docs.
- **Today card**: the reference's "Today in ‹alias›" kicker on the Today summary card arrives with that card in Phase 5 (KIW-39), and reuses the Today title function.

## Testing Decisions

- Tests check what a person sees or what a store returns, never how a view is built.
- **Household store** (existing recorded-server tests in `KiwiDataTests`): a household returned as `"  The Burrow "` loads as a `Household` whose alias is `"The Burrow"`. This covers trimming through the real loading path, without adding a `KiwiDomain` test target.
- **Title copy** (existing screen-copy pattern in `KiwiFeaturesTests`, like the no-household message): ported from the reference's "names the household in the header once its alias loads" cases for Today and Pets, with "The Burrow" giving "Today in The Burrow" and "Pets in The Burrow".
- **Settings row**: `#Preview`s (light, dark) and the simulator check; it only displays the alias.
- The reference's fallback-title cases aren't ported, because iOS can't reach that state (see Implementation Decisions).

## Out of Scope

- Editing the Household alias, and showing a changed alias without relaunching: these come with a household-edit feature, which isn't planned yet.
- Household Members in Settings (KIW-91) and the Appearance setting (KIW-41).
- The Today summary card's kicker (Phase 5, KIW-39) and the real Today and Pets screens (Phase 3).
- Any schema change, including renaming the `alias` column.

## Further Notes

- Validate on the local stack signed in as a seeded Account, then on the shared project with `make run-shared` for the developer's check.
- The parity comparison is per screen section: compare the titles and the Household section with the reference's `TodayScreen`, `PetsScreen` and `HouseholdSection` and their tests, and note the "Alias" label as the agreed difference.
