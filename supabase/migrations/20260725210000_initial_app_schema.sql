create schema app authorization postgres;

revoke all on schema app from public, anon, authenticated;

create function app.set_updated_at()
returns trigger
language plpgsql
-- An empty search path prevents objects in writable schemas from shadowing dependencies.
set search_path = ''
as $$
begin
  -- Defaults use transaction time; updates use statement time so this value advances within a transaction.
  new.updated_at = statement_timestamp();
  return new;
end;
$$;

create table app.users (
  id uuid primary key references auth.users (id) on delete cascade,
  deletion_requested_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table app.characters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app.users (id) on delete cascade,
  generation integer not null,
  name text not null,
  born_at timestamptz not null default now(),
  farewelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint characters_generation_positive check (generation > 0),
  constraint characters_name_not_blank check (btrim(name) <> ''),
  constraint characters_farewell_after_birth check (
    farewelled_at is null or farewelled_at >= born_at
  ),
  constraint characters_user_generation_unique unique (user_id, generation),
  -- This target key lets meal ownership be enforced by a composite foreign key.
  constraint characters_id_user_unique unique (id, user_id),
  -- This target key keeps farewell history synchronized with the character timestamp.
  constraint characters_id_farewelled_at_unique unique (id, farewelled_at)
);

create unique index characters_one_active_per_user_idx
  on app.characters (user_id)
  where farewelled_at is null;

create table app.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  character_id uuid not null,
  occurred_at timestamptz not null,
  utc_offset_minutes smallint not null,
  dish_name text not null,
  is_katsuona_dish boolean not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint meals_utc_offset_range check (
    utc_offset_minutes between -840 and 840
  ),
  constraint meals_dish_name_not_blank check (btrim(dish_name) <> ''),
  constraint meals_character_user_fk
    foreign key (character_id, user_id)
    references app.characters (id, user_id)
    on delete cascade,
  -- This target key ensures a farewell can only reference a meal from its character.
  constraint meals_id_character_unique unique (id, character_id)
);

create index meals_user_occurred_at_idx
  on app.meals (user_id, occurred_at desc);

create index meals_character_occurred_at_idx
  on app.meals (character_id, occurred_at);

create table app.meal_photos (
  meal_id uuid primary key references app.meals (id) on delete cascade,
  object_key text not null,
  content_type text not null,
  byte_size bigint not null,
  width integer not null,
  height integer not null,
  created_at timestamptz not null default now(),
  constraint meal_photos_object_key_not_blank check (btrim(object_key) <> ''),
  constraint meal_photos_content_type_not_blank check (btrim(content_type) <> ''),
  constraint meal_photos_byte_size_positive check (byte_size > 0),
  constraint meal_photos_width_positive check (width > 0),
  constraint meal_photos_height_positive check (height > 0),
  constraint meal_photos_object_key_unique unique (object_key)
);

create table app.farewells (
  character_id uuid primary key,
  trigger_meal_id uuid not null unique,
  farewelled_at timestamptz not null,
  created_at timestamptz not null default now(),
  constraint farewells_character_time_fk
    foreign key (character_id, farewelled_at)
    references app.characters (id, farewelled_at)
    on delete cascade,
  constraint farewells_trigger_meal_character_fk
    foreign key (trigger_meal_id, character_id)
    references app.meals (id, character_id)
    on delete restrict
);

create trigger users_set_updated_at
before update on app.users
for each row execute function app.set_updated_at();

create trigger characters_set_updated_at
before update on app.characters
for each row execute function app.set_updated_at();

create trigger meals_set_updated_at
before update on app.meals
for each row execute function app.set_updated_at();
