begin;

select plan(45);

select has_schema('app', 'application schema exists');
select has_table('app', 'users', 'users table exists');
select has_table('app', 'characters', 'characters table exists');
select has_table('app', 'meals', 'meals table exists');
select has_table('app', 'meal_photos', 'meal_photos table exists');
select has_table('app', 'farewells', 'farewells table exists');

select col_is_pk('app', 'users', 'id', 'users.id is the primary key');
select col_is_pk('app', 'characters', 'id', 'characters.id is the primary key');
select col_is_pk('app', 'meals', 'id', 'meals.id is the primary key');
select col_is_pk(
  'app',
  'meal_photos',
  'meal_id',
  'meal_photos.meal_id is the primary key'
);
select col_is_pk(
  'app',
  'farewells',
  'character_id',
  'farewells.character_id is the primary key'
);

select has_index(
  'app',
  'characters',
  'characters_one_active_per_user_idx',
  'a user can have at most one active character'
);
select has_index(
  'app',
  'characters',
  'characters_user_generation_unique',
  'character generations are unique per user'
);
select has_index(
  'app',
  'characters',
  'characters_id_farewelled_at_unique',
  'character farewell timestamps can be referenced as a target key'
);
select has_index(
  'app',
  'meals',
  'meals_user_occurred_at_idx',
  'meal history has a user and occurred_at index'
);
select has_index(
  'app',
  'meal_photos',
  'meal_photos_object_key_unique',
  'R2 object keys are unique'
);
select has_index(
  'app',
  'farewells',
  'farewells_trigger_meal_id_key',
  'a meal can trigger at most one farewell'
);
select ok(
  not has_schema_privilege('anon', 'app', 'usage'),
  'anonymous Data API role cannot access the app schema'
);
select ok(
  not has_schema_privilege('authenticated', 'app', 'usage'),
  'authenticated Data API role cannot access the app schema'
);

insert into auth.users (id, created_at, updated_at)
values
  ('10000000-0000-0000-0000-000000000001', statement_timestamp(), statement_timestamp()),
  ('10000000-0000-0000-0000-000000000002', statement_timestamp(), statement_timestamp()),
  ('10000000-0000-0000-0000-000000000003', statement_timestamp(), statement_timestamp());

insert into app.users (id)
values
  ('10000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002'),
  ('10000000-0000-0000-0000-000000000003');

insert into app.characters (id, user_id, generation, name, born_at)
values (
  '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  1,
  'だしトモ1号',
  '2026-07-01 00:00:00+00'
);

select throws_ok(
  $test$
    insert into app.characters (user_id, generation, name)
    values ('10000000-0000-0000-0000-000000000001', 0, 'テスト')
  $test$,
  '23514',
  null,
  'generation zero is rejected'
);

select throws_ok(
  $test$
    insert into app.characters (user_id, generation, name)
    values ('10000000-0000-0000-0000-000000000001', 2, 'テスト')
  $test$,
  '23505',
  null,
  'a second active character is rejected'
);

select throws_ok(
  $test$
    insert into app.characters (user_id, generation, name)
    values ('10000000-0000-0000-0000-000000000002', 1, '   ')
  $test$,
  '23514',
  null,
  'a blank character name is rejected'
);

update app.characters
set farewelled_at = '2026-07-10 00:00:00+00'
where id = '20000000-0000-0000-0000-000000000001';

select lives_ok(
  $test$
    insert into app.characters (id, user_id, generation, name, born_at)
    values (
      '20000000-0000-0000-0000-000000000002',
      '10000000-0000-0000-0000-000000000001',
      2,
      'だしトモ2号',
      '2026-07-10 00:00:00+00'
    )
  $test$,
  'the next generation can be created after farewell'
);

select throws_ok(
  $test$
    insert into app.characters (
      user_id,
      generation,
      name,
      born_at,
      farewelled_at
    )
    values (
      '10000000-0000-0000-0000-000000000002',
      1,
      'テスト',
      '2026-07-10 00:00:00+00',
      '2026-07-09 00:00:00+00'
    )
  $test$,
  '23514',
  null,
  'farewell before birth is rejected'
);

insert into app.characters (id, user_id, generation, name)
values (
  '20000000-0000-0000-0000-000000000003',
  '10000000-0000-0000-0000-000000000002',
  1,
  'だしトモ3号'
);

select lives_ok(
  $test$
    update app.characters
    set farewelled_at = now()
    where id = '20000000-0000-0000-0000-000000000003'
  $test$,
  'a character can be farewelled with now in its creation transaction'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values (
  '30000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001',
  '2026-07-09 12:00:00+00',
  540,
  'かつお菜の雑煮',
  true
);

select throws_ok(
  $test$
    insert into app.meals (
      user_id,
      character_id,
      occurred_at,
      utc_offset_minutes,
      dish_name,
      is_katsuona_dish
    )
    values (
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000002',
      statement_timestamp(),
      841,
      '朝食',
      false
    )
  $test$,
  '23514',
  null,
  'UTC offset outside the supported range is rejected'
);

select throws_ok(
  $test$
    insert into app.meals (
      user_id,
      character_id,
      occurred_at,
      utc_offset_minutes,
      dish_name,
      is_katsuona_dish
    )
    values (
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000002',
      statement_timestamp(),
      540,
      '   ',
      false
    )
  $test$,
  '23514',
  null,
  'a blank dish name is rejected'
);

select throws_ok(
  $test$
    insert into app.meals (
      user_id,
      character_id,
      occurred_at,
      utc_offset_minutes,
      dish_name,
      is_katsuona_dish
    )
    values (
      '10000000-0000-0000-0000-000000000002',
      '20000000-0000-0000-0000-000000000002',
      statement_timestamp(),
      540,
      '昼食',
      false
    )
  $test$,
  '23503',
  null,
  'a meal cannot reference another user character'
);

insert into app.meal_photos (
  meal_id,
  object_key,
  content_type,
  byte_size,
  width,
  height
)
values (
  '30000000-0000-0000-0000-000000000001',
  'meals/10000000-0000-0000-0000-000000000001/photo.jpg',
  'image/jpeg',
  1024,
  800,
  600
);

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id,
      object_key,
      content_type,
      byte_size,
      width,
      height
    )
    values (
      '30000000-0000-0000-0000-000000000001',
      'meals/duplicate/photo.jpg',
      'image/jpeg',
      1024,
      800,
      600
    )
  $test$,
  '23505',
  null,
  'a meal cannot have a second photo'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values (
  '30000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000002',
  '2026-07-11 12:00:00+00',
  540,
  '昼食',
  false
);

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id,
      object_key,
      content_type,
      byte_size,
      width,
      height
    )
    values (
      '30000000-0000-0000-0000-000000000002',
      'meals/10000000-0000-0000-0000-000000000001/photo.jpg',
      'image/jpeg',
      2048,
      1200,
      900
    )
  $test$,
  '23505',
  null,
  'an R2 object key cannot be reused'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values
  (
    '30000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '2026-07-12 08:00:00+00',
    540,
    '朝食',
    false
  ),
  (
    '30000000-0000-0000-0000-000000000005',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '2026-07-12 12:00:00+00',
    540,
    '昼食',
    false
  ),
  (
    '30000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '2026-07-12 15:00:00+00',
    540,
    '間食',
    false
  ),
  (
    '30000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '2026-07-12 18:00:00+00',
    540,
    '夕食',
    false
  );

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id, object_key, content_type, byte_size, width, height
    )
    values (
      '30000000-0000-0000-0000-000000000004',
      'meals/blank-content-type.jpg',
      '   ',
      1024,
      800,
      600
    )
  $test$,
  '23514',
  null,
  'a blank photo content type is rejected'
);

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id, object_key, content_type, byte_size, width, height
    )
    values (
      '30000000-0000-0000-0000-000000000005',
      'meals/zero-byte-size.jpg',
      'image/jpeg',
      0,
      800,
      600
    )
  $test$,
  '23514',
  null,
  'a non-positive photo byte size is rejected'
);

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id, object_key, content_type, byte_size, width, height
    )
    values (
      '30000000-0000-0000-0000-000000000006',
      'meals/zero-width.jpg',
      'image/jpeg',
      1024,
      0,
      600
    )
  $test$,
  '23514',
  null,
  'a non-positive photo width is rejected'
);

select throws_ok(
  $test$
    insert into app.meal_photos (
      meal_id, object_key, content_type, byte_size, width, height
    )
    values (
      '30000000-0000-0000-0000-000000000007',
      'meals/zero-height.jpg',
      'image/jpeg',
      1024,
      800,
      0
    )
  $test$,
  '23514',
  null,
  'a non-positive photo height is rejected'
);

update app.users
set
  deletion_requested_at = now(),
  updated_at = '2000-01-01 00:00:00+00'
where id = '10000000-0000-0000-0000-000000000001';

select isnt(
  (
    select updated_at
    from app.users
    where id = '10000000-0000-0000-0000-000000000001'
  ),
  '2000-01-01 00:00:00+00'::timestamptz,
  'the user trigger overrides a supplied updated_at'
);

update app.characters
set updated_at = '2000-01-01 00:00:00+00'
where id = '20000000-0000-0000-0000-000000000002';

select isnt(
  (
    select updated_at
    from app.characters
    where id = '20000000-0000-0000-0000-000000000002'
  ),
  '2000-01-01 00:00:00+00'::timestamptz,
  'the character trigger overrides a supplied updated_at'
);

update app.meals
set
  dish_name = '昼食（更新）',
  updated_at = '2000-01-01 00:00:00+00'
where id = '30000000-0000-0000-0000-000000000002';

select isnt(
  (
    select updated_at
    from app.meals
    where id = '30000000-0000-0000-0000-000000000002'
  ),
  '2000-01-01 00:00:00+00'::timestamptz,
  'the meal trigger overrides a supplied updated_at'
);

select lives_ok(
  $test$
    insert into app.farewells (
      character_id,
      trigger_meal_id,
      farewelled_at
    )
    values (
      '20000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000001',
      '2026-07-10 00:00:00+00'
    )
  $test$,
  'a farewell can reference a meal from the same character'
);

select throws_ok(
  $test$
    update app.characters
    set farewelled_at = '2026-07-11 00:00:00+00'
    where id = '20000000-0000-0000-0000-000000000001'
  $test$,
  '23503',
  null,
  'a character farewell timestamp is immutable while its farewell exists'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values (
  '30000000-0000-0000-0000-000000000003',
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001',
  '2026-07-09 18:00:00+00',
  540,
  '夕食',
  false
);

select throws_ok(
  $test$
    insert into app.farewells (
      character_id,
      trigger_meal_id,
      farewelled_at
    )
    values (
      '20000000-0000-0000-0000-000000000002',
      '30000000-0000-0000-0000-000000000003',
      '2026-07-12 00:00:00+00'
    )
  $test$,
  '23503',
  null,
  'a farewell trigger meal must belong to its character'
);

select throws_ok(
  $test$
    insert into app.farewells (
      character_id,
      trigger_meal_id,
      farewelled_at
    )
    values (
      '20000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000001',
      '2026-07-12 00:00:00+00'
    )
  $test$,
  '23505',
  null,
  'a character can be farewelled only once'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values (
  '30000000-0000-0000-0000-000000000008',
  '10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000003',
  now(),
  540,
  'かつお菜のおひたし',
  true
);

select throws_ok(
  $test$
    insert into app.farewells (
      character_id,
      trigger_meal_id,
      farewelled_at
    )
    values (
      '20000000-0000-0000-0000-000000000003',
      '30000000-0000-0000-0000-000000000008',
      '2000-01-01 00:00:00+00'
    )
  $test$,
  '23503',
  null,
  'farewell history must use the character farewell timestamp'
);

insert into app.farewells (
  character_id,
  trigger_meal_id,
  farewelled_at
)
select
  id,
  '30000000-0000-0000-0000-000000000008',
  farewelled_at
from app.characters
where id = '20000000-0000-0000-0000-000000000003';

select throws_ok(
  $test$
    delete from app.meals
    where id = '30000000-0000-0000-0000-000000000008'
  $test$,
  '23503',
  null,
  'a meal that triggered a farewell cannot be deleted'
);

insert into app.characters (
  id,
  user_id,
  generation,
  name,
  born_at,
  farewelled_at
)
values (
  '20000000-0000-0000-0000-000000000004',
  '10000000-0000-0000-0000-000000000003',
  1,
  'だしトモ4号',
  '2026-07-01 00:00:00+00',
  '2026-07-02 00:00:00+00'
);

insert into app.meals (
  id,
  user_id,
  character_id,
  occurred_at,
  utc_offset_minutes,
  dish_name,
  is_katsuona_dish
)
values (
  '30000000-0000-0000-0000-000000000009',
  '10000000-0000-0000-0000-000000000003',
  '20000000-0000-0000-0000-000000000004',
  '2026-07-02 00:00:00+00',
  540,
  'かつお菜の雑煮',
  true
);

insert into app.farewells (
  character_id,
  trigger_meal_id,
  farewelled_at
)
values (
  '20000000-0000-0000-0000-000000000004',
  '30000000-0000-0000-0000-000000000009',
  '2026-07-02 00:00:00+00'
);

select lives_ok(
  $test$
    delete from app.users
    where id = '10000000-0000-0000-0000-000000000003'
  $test$,
  'deleting an application user removes its complete aggregate'
);

select results_eq(
  $test$
    select count(*)::bigint
    from app.meals
    where character_id = '20000000-0000-0000-0000-000000000001'
  $test$,
  array[2::bigint],
  'meal count is derived from meals'
);

select * from finish();
rollback;
