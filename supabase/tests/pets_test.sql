-- Who can read and write pets: their household's members, nobody else.
-- Covers: PET-033, PET-034, PET-035
begin;
select plan(13);

-- A member of Home, a member of Other, and a pet in each household.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@pets.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@pets.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (user_id, household_id, display_name) values
  ('a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');
insert into public.pets (id, household_id, name, species) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Kiwi', 'Cat'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Biscuit', 'Dog');

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select id from public.pets $$,
  array['c0000000-0000-4000-8000-000000000001'::uuid],
  'A member sees their household''s pets and no others'
);
select lives_ok(
  $$ insert into public.pets (id, household_id, name, species)
     values ('c0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'Luna', 'Dog') $$,
  'A member can add a pet to their household'
);
select isnt_empty(
  $$ update public.pets set name = 'Kiwi II' where id = 'c0000000-0000-4000-8000-000000000001' returning id $$,
  'A member can edit their household''s pet'
);
select throws_ok(
  $$ update public.pets set household_id = 'b0000000-0000-4000-8000-000000000002'
     where id = 'c0000000-0000-4000-8000-000000000001' $$,
  '42501',
  'new row violates row-level security policy for table "pets"',
  'A member can''t move a pet to a household they aren''t in'
);
select isnt_empty(
  $$ delete from public.pets where id = 'c0000000-0000-4000-8000-000000000003' returning id $$,
  'A member can delete their household''s pet'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select id from public.pets where household_id = 'b0000000-0000-4000-8000-000000000001' $$,
  'An outsider sees none of the household''s pets'
);
select throws_ok(
  $$ insert into public.pets (household_id, name, species)
     values ('b0000000-0000-4000-8000-000000000001', 'Intruder', 'Cat') $$,
  '42501',
  'new row violates row-level security policy for table "pets"',
  'An outsider can''t add a pet to the household'
);
select is_empty(
  $$ update public.pets set name = 'Taken' where id = 'c0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t edit the household''s pet'
);
select is_empty(
  $$ delete from public.pets where id = 'c0000000-0000-4000-8000-000000000001' returning id $$,
  'An outsider can''t delete the household''s pet'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select throws_ok(
  $$ select id from public.pets $$,
  '42501', 'permission denied for table pets',
  'A signed-out user can''t read pets'
);
select throws_ok(
  $$ insert into public.pets (household_id, name, species)
     values ('b0000000-0000-4000-8000-000000000001', 'Stray', 'Cat') $$,
  '42501', 'permission denied for table pets',
  'A signed-out user can''t add a pet'
);
select throws_ok(
  $$ update public.pets set name = 'Taken' $$,
  '42501', 'permission denied for table pets',
  'A signed-out user can''t edit a pet'
);
select throws_ok(
  $$ delete from public.pets $$,
  '42501', 'permission denied for table pets',
  'A signed-out user can''t delete a pet'
);

select * from finish();
rollback;
