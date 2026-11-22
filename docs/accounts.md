# Setting up Accounts

How to add an Account, its Household and its Member on the shared project.
Nobody can do this from the app: public sign-up is off (**Authentication → Sign
In / Providers → Allow new users to sign up** is turned off), and Households
and Display names are set by hand.

1. In **Authentication → Users**, choose **Add user → Create new user**, enter
   the email and a password, and keep **Auto Confirm User** ticked.
2. Add the Account to a Household right away: until it has one, the app shows
   "This account isn't in a household yet" instead of opening. If the
   Household is new, insert a row in `households` in **Table Editor**, with its
   `alias`.
3. Insert a row in `household_members` with the Account's user ID, the
   Household's ID and a `display_name`, the name the app shows for them instead
   of their email.

Accounts on the shared project don't exist on the local stack, which has its
own seeded ones ([README](../README.md#run)).
