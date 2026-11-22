# Reinstalling the iOS app stays signed in

Status: ready-for-agent

supabase-swift keeps the Session in the Keychain, which iOS keeps when the app
is deleted, so after reinstalling, the iOS app opens signed in. The Expo app
keeps its Session in storage deleted with the app, so it shows sign-in again.

Match the reference: on the first launch after an install, clear any Session
left in the Keychain before the app restores one, so a reinstall shows the
sign-in form. Launches after that keep restoring the Session as they do now.

Done when, on the shared project, deleting and reinstalling the app shows an
empty sign-in form, and relaunching without reinstalling stays signed in.

## Comments
