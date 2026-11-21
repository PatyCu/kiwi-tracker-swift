# Wait for the household after sign-in

Status: done

Port the reference's household loading (`src/modules/households/state/HouseholdProvider.tsx`, `persistence/householdStore.ts`), the waiting states in its root layout (`src/app/_layout.tsx`, `RootStack`) and `ui/NoHouseholdScreen.tsx` to iOS. Follow `.claude/skills/port-feature/SKILL.md`.

- After sign-in the app loads the signed-in Account's Household (id and alias) before showing the tabs: loading, then the tabs, an error with Retry (`LoadErrorView`), or the no-household screen. The tabs only open once it's loaded.
- A `HouseholdModel` is created for each sign-in, inside the `.signedIn` branch of `SessionRoot` (`AppShell/AppRoot.swift`), next to the existing "new shell for each sign-in" rule, so a new Account never sees the previous Household. The loaded Household reaches the tabs through the environment, ready for KIW-88.
- Retry reloads only the Household for now. Features that load alongside it later (pets, events, calendar events) add themselves to this Retry, as the reference's `RootStack` does.
- Retry and "Check again" show loading again while they run, and pick up a membership added since the last check.
- No-household screen copy, verbatim: "This account isn't in a household yet" and "<email> needs to be added to a household before you can use Kiwi Tracker. Ask whoever set up your account, then check again.", with "Check again" and "Sign out". A failed sign-out shows "Could not sign out. Try again."
- Port the cases of `HouseholdProvider.test.tsx`, `NoHouseholdScreen.test.tsx` and `householdStore.test.ts` case for case.

Done when, on the shared project, an Account with a Household sees the tabs after a brief loading state, and a load with the network off shows the error, whose Retry opens the app once it's back. Every seeded Account has a Household, so the no-household screen is checked on the local stack by removing one Account's membership (Check again after adding it back opens the app; Sign out works).

## Comments

- 2026-11-21: Done. `NoHouseholdScreen` takes the email, Check again and a Sign out slot from `AppRoot`, which passes Auth's `SignOutButton`, so `Households` doesn't depend on `Auth`. Checked on the local stack (missing, Check again, Sign out, membership added back) and on the shared project (loading, network-off error, Retry). Not compared side by side with the running reference; the copy and states were compared against the reference code and tests.
