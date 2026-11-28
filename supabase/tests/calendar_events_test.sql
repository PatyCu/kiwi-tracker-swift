-- Who can read and add calendar events: the pet's household's members, nobody
-- else. Nobody can edit or delete them.
begin;
select plan(12);

-- A member of Home, a member of Other, and a pet with a calendar event in each household.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@calendar-events.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@calendar-events.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (user_id, household_id, display_name) values
  ('a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');
insert into public.pets (id, household_id, name, species) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Kiwi', 'Cat'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Biscuit', 'Dog');
insert into public.calendar_events (id, pet_id, title, starts_at, ends_at) values
  ('e0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', 'Vet visit', now(), now() + interval '1 hour'),
  ('e0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', 'Vaccine', now(), now() + interval '1 hour');

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select id from public.calendar_events $$,
  array['e0000000-0000-4000-8000-000000000001'::uuid],
  'A member sees their household''s pets'' calendar events and no others'
);
select lives_ok(
  $$ insert into public.calendar_events (pet_id, title, starts_at, ends_at)
     values ('c0000000-0000-4000-8000-000000000001', 'Check-up', now(), now() + interval '1 hour') $$,
  'A member can add a calendar event for their household''s pet'
);
select is_empty(
  $$ update public.calendar_events set title = 'Moved' where id = 'e0000000-0000-4000-8000-000000000001' returning id $$,
  'A member can''t edit a calendar event'
);
select is_empty(
  $$ delete from public.calendar_events where id = 'e0000000-0000-4000-8000-000000000001' returning id $$,
  'A member can''t delete a calendar event'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select id from public.calendar_events where pet_id = 'c0000000-0000-4000-8000-000000000001' $$,
  'An outsider sees none of the household''s pets'' calendar events'
);
select throws_ok(
  $$ insert into public.calendar_events (pet_id, title, starts_at, ends_at)
     values ('c0000000-0000-4000-8000-000000000001', 'Intrusion', now(), now() + interval '1 hour') $$,
  '42501',
  'new row violates row-level security policy for table "calendar_events"',
  'An outsider can''t add a calendar event for the household''s pet'
);
select is_empty(
  $$ update public.calendar_events set title = 'Taken' where id = 'e0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t edit the household''s calendar event'
);
select is_empty(
  $$ delete from public.calendar_events where id = 'e0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t delete the household''s calendar event'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select throws_ok(
  $$ select id from public.calendar_events $$,
  '42501', 'permission denied for table calendar_events',
  'A signed-out user can''t read calendar events'
);
select throws_ok(
  $$ insert into public.calendar_events (pet_id, title, starts_at, ends_at)
     values ('c0000000-0000-4000-8000-000000000001', 'Stray', now(), now() + interval '1 hour') $$,
  '42501', 'permission denied for table calendar_events',
  'A signed-out user can''t add a calendar event'
);
select throws_ok(
  $$ update public.calendar_events set title = 'Taken' $$,
  '42501', 'permission denied for table calendar_events',
  'A signed-out user can''t edit a calendar event'
);
select throws_ok(
  $$ delete from public.calendar_events $$,
  '42501', 'permission denied for table calendar_events',
  'A signed-out user can''t delete a calendar event'
);

select * from finish();
rollback;
