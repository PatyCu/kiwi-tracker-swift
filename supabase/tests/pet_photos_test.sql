-- Who can read and write pet photos: members of the pet's household, in the pet's folder, nobody else.
begin;
select plan(15);

-- A member of Home, a member of Other, a pet in each household, and a photo of each pet.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000001', 'member@photos.test'),
  ('a0000000-0000-4000-8000-000000000003', 'outsider@photos.test');
insert into public.households (id, alias) values
  ('b0000000-0000-4000-8000-000000000001', 'Home'),
  ('b0000000-0000-4000-8000-000000000002', 'Other');
insert into public.household_members (user_id, household_id, display_name) values
  ('a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Member'),
  ('a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Outsider');
insert into public.pets (id, household_id, name, species) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Kiwi', 'Cat'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'Biscuit', 'Dog');
insert into storage.objects (bucket_id, name) values
  ('pet-photos', 'c0000000-0000-4000-8000-000000000001/1.jpg'),
  ('pet-photos', 'c0000000-0000-4000-8000-000000000002/1.jpg');

-- The Storage API allows deleting rows this way; without it, any delete raises.
set local storage.allow_delete_query = 'true';

-- A member of Home --------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000001", "role": "authenticated"}';

select results_eq(
  $$ select name from storage.objects where bucket_id = 'pet-photos' $$,
  array['c0000000-0000-4000-8000-000000000001/1.jpg'],
  'A member sees their household''s pets'' photos and no others'
);
select lives_ok(
  $$ insert into storage.objects (bucket_id, name)
     values ('pet-photos', 'c0000000-0000-4000-8000-000000000001/2.jpg') $$,
  'A member can upload a photo to their household''s pet''s folder'
);
select isnt_empty(
  $$ update storage.objects set metadata = '{"size": 1}'
     where bucket_id = 'pet-photos' and name = 'c0000000-0000-4000-8000-000000000001/2.jpg'
     returning name $$,
  'A member can replace a photo of their household''s pet'
);
select isnt_empty(
  $$ delete from storage.objects
     where bucket_id = 'pet-photos' and name = 'c0000000-0000-4000-8000-000000000001/2.jpg'
     returning name $$,
  'A member can delete a photo of their household''s pet'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name)
     values ('pet-photos', 'c0000000-0000-4000-8000-000000000002/2.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "objects"',
  'A member can''t upload a photo to another household''s pet''s folder'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name) values ('pet-photos', 'loose.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "objects"',
  'A member can''t upload a photo outside any pet''s folder'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name) values ('pet-photos', 'not-a-pet/1.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "objects"',
  'A member can''t upload a photo to a folder that isn''t a pet''s'
);

-- A member of another household --------------------------------------------------

set local request.jwt.claims = '{"sub": "a0000000-0000-4000-8000-000000000003", "role": "authenticated"}';

select is_empty(
  $$ select name from storage.objects
     where bucket_id = 'pet-photos' and name like 'c0000000-0000-4000-8000-000000000001/%' $$,
  'An outsider sees none of the household''s pets'' photos'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name)
     values ('pet-photos', 'c0000000-0000-4000-8000-000000000001/3.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "objects"',
  'An outsider can''t upload a photo of the household''s pet'
);
select is_empty(
  $$ update storage.objects set metadata = '{"size": 1}'
     where bucket_id = 'pet-photos' and name = 'c0000000-0000-4000-8000-000000000001/1.jpg'
     returning name $$,
  'An outsider can''t replace a photo of the household''s pet'
);
select is_empty(
  $$ delete from storage.objects
     where bucket_id = 'pet-photos' and name = 'c0000000-0000-4000-8000-000000000001/1.jpg'
     returning name $$,
  'An outsider can''t delete a photo of the household''s pet'
);

-- A signed-out user --------------------------------------------------------------

reset role;
set local role anon;
set local request.jwt.claims = '{"role": "anon"}';

select is_empty(
  $$ select name from storage.objects where bucket_id = 'pet-photos' $$,
  'A signed-out user can''t read pet photos'
);
select throws_ok(
  $$ insert into storage.objects (bucket_id, name)
     values ('pet-photos', 'c0000000-0000-4000-8000-000000000001/4.jpg') $$,
  '42501',
  'new row violates row-level security policy for table "objects"',
  'A signed-out user can''t upload a pet photo'
);
select is_empty(
  $$ update storage.objects set metadata = '{"size": 1}' where bucket_id = 'pet-photos' returning name $$,
  'A signed-out user can''t replace a pet photo'
);
select is_empty(
  $$ delete from storage.objects where bucket_id = 'pet-photos' returning name $$,
  'A signed-out user can''t delete a pet photo'
);

select * from finish();
rollback;
