# Reinstalling the iOS app stays signed in

Status: done

## Problem Statement

After deleting and reinstalling the iOS app, it opens signed in to the previous Account. supabase-swift keeps the Session in the Keychain, which iOS keeps when the app is deleted. The Expo app keeps its Session in storage deleted with the app, so a reinstall shows sign-in again. Logged in 8ee1673.

## Solution

On the first launch after an install, the app clears any Session left in the Keychain before it restores one, so a reinstall shows an empty sign-in form. Launches after that restore the Session as they do now. The Session is kept on this device only, so a backup never carries it to another device.

## User Stories

1. As a person who deleted and reinstalled the app, I want to see the sign-in form, so that a reinstall starts fresh, as in the Expo app.
2. As a person handing a device to someone else after deleting the app, I want a reinstall not to open my Account, so that the next person can't see my Household.
3. As a signed-in Member, I want relaunching the app (without reinstalling) to keep me signed in, so that I don't sign in every time.
4. As a signed-in Member, I want the app to stay signed in after a device restart, so that only a reinstall ends my Session.
5. As a person reinstalling, I want the sign-in form empty, so that nothing from the previous Account shows.
6. As a person reinstalling, I want the old Session cleared even if clearing failed on an earlier launch, so that a passing Keychain error doesn't leave me signed in for good.
7. As a Member who already has the app installed, I accept being signed out once on the first launch of this fix, since that install has never recorded a launch.
8. As a Member restoring a backup onto a new device, I want to sign in again there, so that a backup never carries my Session to another device.

## Implementation Decisions

- **Where the Session lives**: it stays in the Keychain, through a Keychain storage `KiwiData` owns instead of supabase-swift's. It keeps the Session on this device only (`AfterFirstUnlockThisDeviceOnly`; supabase-swift's storage uses `AfterFirstUnlock`, which backups carry to other devices). Reading or removing a missing Session isn't an error, as the SDK's storage protocol documents (supabase-swift's own Keychain storage throws for both, with an error type it doesn't expose). It uses supabase-swift's Keychain service name, so the item written before this fix is the one cleared.
- **First launch marker**: a "has launched" flag in UserDefaults, which iOS deletes with the app. Its absence means this is the first launch since install.
- **Where it happens**: in `KiwiData`'s `SupabaseBackend`, before the Supabase client is built, because the client emits the stored Session as its initial one. Nothing outside `KiwiData` changes.
- **Interface**: the backend's test init takes the UserDefaults alongside the Session storage and `URLSession`; the production init keeps its current signature and passes the Keychain storage and the standard UserDefaults.
- **Storage key**: the backend passes the Session's storage key to the client explicitly, using the key supabase-swift uses by default, so the key it clears is the key the client reads and existing Sessions are found.
- **Failure**: the flag is set only after the stored Session is removed; removing a missing Session succeeds. If removal throws, the flag stays unset, this launch restores the Session, and the next launch tries again.
- **Server**: clearing is local only; the old refresh token is not revoked.
- **Existing installs**: no migration. Installs without the flag are signed out once on the first launch of this fix.
- **No schema change**, no Glossary change.

## Testing Decisions

- Tests check what the app reports, not how storage is called: the first value of `SupabasePasswordAuth.signedInUsers()`, plus whether the stored Session is still there.
- One seam: the backend's test init, built through `RecordedSupabaseServer.backend(...)` with a shared storage and a throwaway UserDefaults suite per test. A "launch" is building a new backend on the same storage, host and defaults.
- Cases in `KiwiDataTests`:
  - First launch after install with a stored Session: reports signed out, and the Session is removed.
  - Later launch with a stored Session: reports the stored user.
  - Removal throws: that launch reports the stored user, and the following launch clears the Session.
- Existing tests that restore a stored Session launch the same install twice, so they still model a later launch.
- The Keychain storage has no unit tests: KiwiKit's tests don't run inside an app, so the Keychain refuses them (`errSecMissingEntitlement`). It's checked on the simulator instead, including that its item is device-only.
- Prior art: the "reports the stored user" tests in `SupabasePasswordAuthTests`, and `InMemorySessionStorage`.
- Manual check on the shared project: delete and reinstall shows an empty sign-in form; relaunching without reinstalling stays signed in.

## Out of Scope

- Revoking the old Session on the server.
- Moving the Session out of the Keychain, or encrypting it with a key deleted with the app.
- Any change to sign-in, sign-out or the Expo app.

## Comments
