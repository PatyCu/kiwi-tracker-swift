# Kiwi Tracker

Pet care and health tracking for households: the pets, the events logged about them, and the people who share them.

## Language

**Account**:
A person's email-and-password sign-in. Accounts are created in the Supabase dashboard, never in the app.
_Avoid_: User, login

**Session**:
One device's stored sign-in to an Account. Signing out ends it on that device only.
_Avoid_: Login, auth
