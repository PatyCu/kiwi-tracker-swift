-- Who can read households: their members, nobody else. Only the dashboard
-- creates, edits or deletes them.
-- Covers: HH-019, HH-020, HH-021
begin;
select plan(9);

-- A member of Home and a member of Other.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@households.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@households.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (id, user_id, household_id, display_name) values
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('f0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select id from public.households $$,
  array['b0000000-0000-4000-8000-000000000001'::uuid],
  'A member sees their household and no others'
);
select throws_ok(
  $$ insert into public.households (alias) values ('New home') $$,
  '42501', 'permission denied for table households',
  'A member can''t create a household'
);
select throws_ok(
  $$ update public.households set alias = 'Renamed' $$,
  '42501', 'permission denied for table households',
  'A member can''t edit a household'
);
select throws_ok(
  $$ delete from public.households $$,
  '42501', 'permission denied for table households',
  'A member can''t delete a household'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select id from public.households where id = 'b0000000-0000-4000-8000-000000000001' $$,
  'An outsider doesn''t see the household'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select throws_ok(
  $$ select id from public.households $$,
  '42501', 'permission denied for table households',
  'A signed-out user can''t read households'
);
select throws_ok(
  $$ insert into public.households (alias) values ('New home') $$,
  '42501', 'permission denied for table households',
  'A signed-out user can''t create a household'
);
select throws_ok(
  $$ update public.households set alias = 'Renamed' $$,
  '42501', 'permission denied for table households',
  'A signed-out user can''t edit a household'
);
select throws_ok(
  $$ delete from public.households $$,
  '42501', 'permission denied for table households',
  'A signed-out user can''t delete a household'
);

select * from finish();
rollback;
