-- Who can read memberships: the household's members, every membership in it,
-- nobody else. Only the dashboard adds, edits or removes them.
-- Covers: HH-019, HH-020, HH-021
begin;
select plan(9);

-- Two members of Home and one of Other.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@household-members.test'),
  ('a0000000-0000-4000-8000-000000000002', 'housemate@household-members.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@household-members.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (id, user_id, household_id, display_name) values
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('f0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'Housemate'),
  ('f0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select id from public.household_members order by id $$,
  array['f0000000-0000-4000-8000-000000000001'::uuid, 'f0000000-0000-4000-8000-000000000002'::uuid],
  'A member sees every membership in their household and no others'
);
select throws_ok(
  $$ insert into public.household_members (user_id, household_id, display_name)
     values ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'Joiner') $$,
  '42501', 'permission denied for table household_members',
  'A member can''t add a membership'
);
select throws_ok(
  $$ update public.household_members set display_name = 'Renamed' $$,
  '42501', 'permission denied for table household_members',
  'A member can''t edit a membership'
);
select throws_ok(
  $$ delete from public.household_members $$,
  '42501', 'permission denied for table household_members',
  'A member can''t remove a membership'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select id from public.household_members where household_id = 'b0000000-0000-4000-8000-000000000001' $$,
  'An outsider sees none of the household''s memberships'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select throws_ok(
  $$ select id from public.household_members $$,
  '42501', 'permission denied for table household_members',
  'A signed-out user can''t read memberships'
);
select throws_ok(
  $$ insert into public.household_members (user_id, household_id, display_name)
     values ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001', 'Joiner') $$,
  '42501', 'permission denied for table household_members',
  'A signed-out user can''t add a membership'
);
select throws_ok(
  $$ update public.household_members set display_name = 'Renamed' $$,
  '42501', 'permission denied for table household_members',
  'A signed-out user can''t edit a membership'
);
select throws_ok(
  $$ delete from public.household_members $$,
  '42501', 'permission denied for table household_members',
  'A signed-out user can''t remove a membership'
);

select * from finish();
rollback;
