-- Who can read and write pet events: the pet's household's members, nobody else.
begin;
select plan(13);

-- A member of Home, a member of Other, and a pet with an event in each household.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@pet-events.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@pet-events.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (user_id, household_id, display_name) values
  ('a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');
insert into public.pets (id, household_id, name, species) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Kiwi', 'Cat'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Biscuit', 'Dog');
insert into public.pet_events (id, pet_id, type, symptom, occurred_at) values
  ('d0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', 'symptom', 'Vomiting', now()),
  ('d0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', 'symptom', 'Nausea', now());

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select id from public.pet_events $$,
  array['d0000000-0000-4000-8000-000000000001'::uuid],
  'A member sees their household''s pets'' events and no others'
);
select lives_ok(
  $$ insert into public.pet_events (id, pet_id, type, symptom, occurred_at)
     values ('d0000000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000001', 'symptom', 'Hairball', now()) $$,
  'A member can add an event for their household''s pet'
);
select isnt_empty(
  $$ update public.pet_events set note = 'After breakfast' where id = 'd0000000-0000-4000-8000-000000000001' returning id $$,
  'A member can edit an event for their household''s pet'
);
select isnt_empty(
  $$ delete from public.pet_events where id = 'd0000000-0000-4000-8000-000000000003' returning id $$,
  'A member can delete an event for their household''s pet'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select id from public.pet_events where pet_id = 'c0000000-0000-4000-8000-000000000001' $$,
  'An outsider sees none of the household''s pets'' events'
);
select throws_ok(
  $$ insert into public.pet_events (pet_id, type, symptom, occurred_at)
     values ('c0000000-0000-4000-8000-000000000001', 'symptom', 'Asthma', now()) $$,
  '42501',
  'new row violates row-level security policy for table "pet_events"',
  'An outsider can''t add an event for the household''s pet'
);
select throws_ok(
  $$ update public.pet_events set pet_id = 'c0000000-0000-4000-8000-000000000001'
     where id = 'd0000000-0000-4000-8000-000000000002' $$,
  '42501',
  'new row violates row-level security policy for table "pet_events"',
  'An outsider can''t move their event onto the household''s pet'
);
select is_empty(
  $$ update public.pet_events set note = 'Taken' where id = 'd0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t edit an event for the household''s pet'
);
select is_empty(
  $$ delete from public.pet_events where id = 'd0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t delete an event for the household''s pet'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select throws_ok(
  $$ select id from public.pet_events $$,
  '42501', 'permission denied for table pet_events',
  'A signed-out user can''t read pet events'
);
select throws_ok(
  $$ insert into public.pet_events (pet_id, type, symptom, occurred_at)
     values ('c0000000-0000-4000-8000-000000000001', 'symptom', 'Asthma', now()) $$,
  '42501', 'permission denied for table pet_events',
  'A signed-out user can''t add a pet event'
);
select throws_ok(
  $$ update public.pet_events set note = 'Taken' $$,
  '42501', 'permission denied for table pet_events',
  'A signed-out user can''t edit a pet event'
);
select throws_ok(
  $$ delete from public.pet_events $$,
  '42501', 'permission denied for table pet_events',
  'A signed-out user can''t delete a pet event'
);

select * from finish();
rollback;
