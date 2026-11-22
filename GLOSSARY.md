# Kiwi Tracker

Pet care and health tracking for households: the pets, the events logged about them, and the people who share them.

## Language

**Account**:
A person's email-and-password sign-in. Accounts are created in the Supabase dashboard, never in the app.
_Avoid_: User, login

**Session**:
One device's stored sign-in to an Account. Signing out ends it on that device only.
_Avoid_: Login, auth

**Household**:
The group of Accounts that share pets. Each Account belongs to at most one. Households are set up by hand, never in the app.
_Avoid_: Family, home, team

**Member**:
An Account in a Household, known there by its **Display name**, never by its email.
_Avoid_: User, owner

**Display name**:
What a Member is called in their Household. Set by hand, never in the app.
_Avoid_: Username, nickname

**Household alias**:
What Members call their Household, shown in titles.
_Avoid_: Household name

**Pet**:
An animal a Household cares for. It belongs to exactly one Household, and every Member sees and manages it. Its species is Cat, Dog or Other.
_Avoid_: Animal, profile

**Event**:
Something about a Pet on a date: either a Pet event or a Calendar event.
_Avoid_: Record, activity, entry

**Pet event**:
An Event logged about a Pet after it happened: a Symptom, a Diet change or Other.
_Avoid_: Log, record

**Calendar event**:
An Event scheduled for a Pet, such as a vet visit, a vaccine or a medicine. It stays a Calendar event after its date and never becomes a Pet event.
_Avoid_: Appointment, reminder
