# Sign out from Settings

Status: done

Port the reference's `AccountSection` (`src/modules/auth/ui/AccountSection.tsx`) to the Settings tab on iOS.

- Settings is a native grouped form with one "Account" section: "Signed in as <email>" and a destructive "Sign out" button. The household alias and members come with KIW-88 and KIW-91.
- One tap signs out, with no confirmation, ending the Session on this device only (local scope). The button reads "Signing out…" while it runs; a failure shows "Could not sign out. Try again." and allows another tap.
- After sign-out the sign-in form is empty. The next sign-in, as the same Account or another, starts on Today with a new navigation stack in every tab.
- Staying signed in across launches already works (Keychain, refreshed at launch); check it once on the shared project.

Done when, on the shared project, signing out from Settings shows an empty sign-in form, the next sign-in starts fresh on Today, and relaunching while signed in stays signed in.

## Comments

- Known quirk, left alone: supabase-swift's `signOut(scope: .local)` removes the Session and reports signed out before it throws for a failed `/logout` call (for example offline), so offline the app still shows sign-in and the error is never seen. supabase-js swallows that error.
