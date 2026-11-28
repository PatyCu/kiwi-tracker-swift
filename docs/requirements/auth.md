# Signing in, Sessions and signing out

### AUTH-001: An Account signs in with its email and password
Status: draft
Migration: same
Source: src/modules/auth/forms/usePasswordSignInForm.ts

A person signs in with the email and password of an existing Account; the app never creates Accounts.

### AUTH-002: The email is normalised and the password sent as typed
Status: draft
Migration: same
Source: src/modules/auth/forms/usePasswordSignInForm.ts

Sign-in sends the email trimmed and lowercased, and the password exactly as typed, spaces included.

### AUTH-003: Sign-in asks for both fields before contacting the server
Status: draft
Migration: same
Source: src/modules/auth/forms/usePasswordSignInForm.ts

Signing in with the email or the password empty shows "Enter your email and password." and sends nothing.

### AUTH-004: Each sign-in failure has its own message
Status: draft
Migration: same
Source: src/modules/auth/forms/usePasswordSignInForm.ts

A failed sign-in shows a different message for wrong credentials, an unconfirmed Account, too many attempts, no connection and any other error, and the person can try again.

### AUTH-005: Editing a field clears the sign-in error
Status: draft
Migration: same
Source: src/modules/auth/forms/usePasswordSignInForm.ts

Changing the email or the password removes the error shown by the last attempt.

### AUTH-006: Signing in shows progress and ignores repeat taps
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInScreen.tsx

While a sign-in runs, its button reads "Signing in…" and further taps start nothing.

### AUTH-007: The password can be shown or hidden
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInScreen.tsx

A "Show password" control switches the password between hidden and visible; it starts hidden.

### AUTH-008: Sign-in is unavailable without a valid backend configuration
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInUnavailableScreen.tsx

When the app's Supabase URL or publishable key is missing or invalid, or the key is a secret key, it shows "Sign-in is not available" instead of the sign-in form.

### AUTH-009: A Session keeps the Account signed in across launches
Status: draft
Migration: same
Source: src/modules/auth/state/SessionProvider.tsx

Relaunching the app, or restarting the device, keeps the Account signed in until it signs out.

### AUTH-010: An expired stored Session is refreshed before the app opens
Status: draft
Migration: same
Source: src/modules/auth/state/SessionProvider.tsx

At launch, the app waits for an expired stored Session to refresh before deciding whether the Account is signed in.

### AUTH-011: A stored Session that can't refresh shows sign-in
Status: draft
Migration: same
Source: src/modules/auth/state/SessionProvider.tsx

When an expired stored Session can't be refreshed, the app shows the sign-in form.

### AUTH-012: A reinstall starts signed out
Status: draft
Migration: same
Source: decision

The first launch after the app is installed shows the sign-in form, even if an earlier install left a Session on the device.

### AUTH-013: A failed reinstall clean-up is retried
Status: draft
Migration: new
Source: decision

If the first launch after an install can't clear the leftover Session, the next launch clears it.

### AUTH-014: A Session never moves to another device
Status: draft
Migration: new
Source: decision

A Session is kept on its device only, so restoring a backup onto another device shows the sign-in form.

### AUTH-015: Settings shows the signed-in email
Status: draft
Migration: same
Source: src/modules/auth/ui/AccountSection.tsx

Settings' Account section shows "Signed in as ‹email›".

### AUTH-016: Signing out ends the Session on this device only
Status: draft
Migration: same
Source: src/modules/auth/ui/AccountSection.tsx

One tap on "Sign out", with no confirmation, ends the Session on this device and leaves the Account's other devices signed in.

### AUTH-017: Signing out shows progress and ignores repeat taps
Status: draft
Migration: same
Source: src/modules/auth/ui/AccountSection.tsx

While a sign-out runs, its button reads "Signing out…" and further taps start nothing.

### AUTH-018: A failed sign-out says so and can be retried
Status: draft
Migration: same
Source: src/modules/auth/ui/AccountSection.tsx

A failed sign-out shows "Could not sign out. Try again." and a new tap clears it and tries again.
Note: offline, the Session ends on the device before the server call fails, so this message isn't seen then.

### AUTH-019: After signing out the sign-in form is empty
Status: draft
Migration: same
Source: src/modules/auth/ui/AccountSection.tsx

Signing out shows the sign-in form with no email or password filled in.

### AUTH-020: Each sign-in starts fresh on Today
Status: draft
Migration: same
Source: src/app/_layout.tsx

The next sign-in, as the same Account or another, opens Today with every tab at its first screen.

### AUTH-021: Launch never flashes the sign-in form
Status: draft
Migration: same
Source: src/app/_layout.tsx

At launch, the app shows an empty screen until it knows whether a Session is stored.

### AUTH-022: The sign-in fields are locked while signing in
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInScreen.tsx

While a sign-in runs, the email and password can't be edited.

### AUTH-023: Return moves from email to password, then signs in
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInScreen.tsx

The keyboard's return key on the email moves to the password, and on the password starts the sign-in.

### AUTH-024: Sign-in opens with the email focused
Status: draft
Migration: same
Source: src/modules/auth/ui/SignInScreen.tsx

The sign-in form opens with the email field focused and the keyboard up.

### AUTH-025: Sign-in unavailable names what is wrong
Status: draft
Migration: same
Source: src/shared/supabase/supabaseConfig.ts

Below "Sign-in is not available", the app names the missing or invalid setting.

### AUTH-026: A Session that stops refreshing while in use shows sign-in
Status: draft
Migration: same
Source: src/modules/auth/state/SessionProvider.tsx

When a Session can no longer be refreshed while the app is open, the app shows the sign-in form.

### AUTH-027: Signing out works offline
Status: draft
Migration: same
Source: src/modules/auth/persistence/passwordAuth.ts

Without a connection, signing out still ends the Session on this device and shows the sign-in form.
