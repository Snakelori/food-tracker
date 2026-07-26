-- ============================================================
--  FOOD TRACKER — Schéma Supabase (PostgreSQL)
--  À exécuter dans : Supabase > SQL Editor > New query
--  Sécurité : Row Level Security (RLS) activée sur toutes les
--  tables de données. Chaque utilisateur ne voit QUE ses données.
-- ============================================================

-- Extensions utiles
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 1. CATÉGORIES (catalogue partagé, en lecture pour tous)
-- ------------------------------------------------------------
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  emoji       text default '🍽️',
  sort_order  int  default 100,
  created_at  timestamptz default now()
);

-- ------------------------------------------------------------
-- 2. PRODUITS
--    user_id NULL  => produit du catalogue par défaut (partagé)
--    user_id défini => produit personnel de l'utilisateur
-- ------------------------------------------------------------
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  user_id     uuid references auth.users(id) on delete cascade,
  name        text not null,
  emoji       text,
  is_active   boolean default true,
  created_at  timestamptz default now()
);
create index if not exists products_category_idx on public.products(category_id);
create index if not exists products_user_idx on public.products(user_id);

-- ------------------------------------------------------------
-- 3. REPAS (petit-déjeuner, déjeuner, dîner, encas)
-- ------------------------------------------------------------
create table if not exists public.meals (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade default auth.uid(),
  meal_date   date not null default current_date,
  meal_type   text not null check (meal_type in ('petit_dejeuner','dejeuner','diner','encas')),
  meal_time   time,
  notes       text,
  created_at  timestamptz default now()
);
create index if not exists meals_user_date_idx on public.meals(user_id, meal_date);

-- ------------------------------------------------------------
-- 4. ALIMENTS D'UN REPAS
--    quantity_kind : 'nombre' (avec quantity_number) OU une taille
-- ------------------------------------------------------------
create table if not exists public.meal_items (
  id              uuid primary key default gen_random_uuid(),
  meal_id         uuid not null references public.meals(id) on delete cascade,
  product_id      uuid references public.products(id) on delete set null,
  custom_name     text,               -- si aliment saisi librement
  quantity_kind   text not null default 'moyenne'
                  check (quantity_kind in ('nombre','petite','moyenne','grande')),
  quantity_number numeric,            -- utilisé si quantity_kind = 'nombre'
  created_at      timestamptz default now()
);
create index if not exists meal_items_meal_idx on public.meal_items(meal_id);

-- ------------------------------------------------------------
-- 5. BOISSONS (liées à un repas ou libres dans la journée)
-- ------------------------------------------------------------
create table if not exists public.drinks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade default auth.uid(),
  meal_id     uuid references public.meals(id) on delete cascade,
  log_date    date not null default current_date,
  drink_type  text not null check (drink_type in
              ('eau','the','cafe','sucree','gazeuse','non_sucree')),
  glasses     numeric not null default 1,   -- nombre de verres
  created_at  timestamptz default now()
);
create index if not exists drinks_user_date_idx on public.drinks(user_id, log_date);

-- ------------------------------------------------------------
-- 6. ÉTAT DE SANTÉ après ingestion
-- ------------------------------------------------------------
create table if not exists public.health_states (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade default auth.uid(),
  meal_id      uuid references public.meals(id) on delete set null,
  log_date     date not null default current_date,
  log_time     time,               -- heure de l'observation
  hours_after  numeric,            -- nb d'heures après le repas
  feeling      int check (feeling between 1 and 5), -- 1=très mal ... 5=très bien
  symptoms     text[],             -- ex: {ballonnement, fatigue}
  description  text,
  created_at   timestamptz default now()
);
create index if not exists health_user_date_idx on public.health_states(user_id, log_date);

-- ------------------------------------------------------------
-- 7. ACTIVITÉS (dépense calorique)
-- ------------------------------------------------------------
create table if not exists public.activities (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade default auth.uid(),
  activity_date date not null default current_date,
  name          text not null,
  duration_min  int,
  intensity     text check (intensity in ('faible','moderee','intense')),
  calories      int,
  created_at    timestamptz default now()
);
create index if not exists activities_user_date_idx on public.activities(user_id, activity_date);

-- ============================================================
--  SÉCURITÉ — Row Level Security
-- ============================================================

-- Catégories : lecture pour tout utilisateur connecté
alter table public.categories enable row level security;
drop policy if exists categories_read on public.categories;
create policy categories_read on public.categories
  for select to authenticated using (true);

-- Produits : lecture du catalogue par défaut + ses produits perso ;
-- écriture uniquement sur ses propres produits.
alter table public.products enable row level security;
drop policy if exists products_read on public.products;
create policy products_read on public.products
  for select to authenticated
  using (user_id is null or user_id = auth.uid());
drop policy if exists products_insert on public.products;
create policy products_insert on public.products
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists products_update on public.products;
create policy products_update on public.products
  for update to authenticated using (user_id = auth.uid());
drop policy if exists products_delete on public.products;
create policy products_delete on public.products
  for delete to authenticated using (user_id = auth.uid());

-- Repas : chacun ses lignes
alter table public.meals enable row level security;
drop policy if exists meals_all on public.meals;
create policy meals_all on public.meals
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Aliments d'un repas : rattachés à un repas appartenant à l'utilisateur
alter table public.meal_items enable row level security;
drop policy if exists meal_items_all on public.meal_items;
create policy meal_items_all on public.meal_items
  for all to authenticated
  using (exists (select 1 from public.meals m
                 where m.id = meal_items.meal_id and m.user_id = auth.uid()))
  with check (exists (select 1 from public.meals m
                 where m.id = meal_items.meal_id and m.user_id = auth.uid()));

-- Boissons
alter table public.drinks enable row level security;
drop policy if exists drinks_all on public.drinks;
create policy drinks_all on public.drinks
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- États de santé
alter table public.health_states enable row level security;
drop policy if exists health_all on public.health_states;
create policy health_all on public.health_states
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Activités
alter table public.activities enable row level security;
drop policy if exists activities_all on public.activities;
create policy activities_all on public.activities
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ============================================================
--  CATALOGUE PAR DÉFAUT (catégories + produits, en français)
--  Réexécutable sans doublon grâce aux gardes NOT EXISTS.
-- ============================================================
insert into public.categories (name, emoji, sort_order)
select v.name, v.emoji, v.sort_order
from (values
  ('Féculents',        '🍚', 10),
  ('Pain & céréales',  '🥖', 20),
  ('Protéines',        '🍗', 30),
  ('Légumes',          '🥦', 40),
  ('Fruits',           '🍎', 50),
  ('Produits laitiers','🧀', 60),
  ('Matières grasses', '🫒', 70),
  ('Plats préparés',   '🍲', 80),
  ('Encas & sucré',    '🍪', 90)
) as v(name, emoji, sort_order)
where not exists (select 1 from public.categories c where c.name = v.name);

-- Produits par défaut (user_id NULL = partagé)
insert into public.products (category_id, name, emoji)
select c.id, p.name, p.emoji
from (values
  -- Féculents
  ('Féculents','Riz','🍚'), ('Féculents','Pâtes','🍝'), ('Féculents','Pommes de terre','🥔'),
  ('Féculents','Semoule','🌾'), ('Féculents','Quinoa','🌿'), ('Féculents','Lentilles','🫘'),
  ('Féculents','Pois chiches','🫛'), ('Féculents','Frites','🍟'),
  -- Pain & céréales
  ('Pain & céréales','Pain','🍞'), ('Pain & céréales','Baguette','🥖'),
  ('Pain & céréales','Pain complet','🥯'), ('Pain & céréales','Biscottes','🍘'),
  ('Pain & céréales','Céréales petit-déj','🥣'), ('Pain & céréales','Flocons d''avoine','🌾'),
  -- Protéines
  ('Protéines','Poulet','🍗'), ('Protéines','Bœuf','🥩'), ('Protéines','Porc','🥓'),
  ('Protéines','Poisson','🐟'), ('Protéines','Saumon','🍣'), ('Protéines','Thon','🐟'),
  ('Protéines','Œufs','🥚'), ('Protéines','Jambon','🍖'), ('Protéines','Tofu','⬜'),
  ('Protéines','Crevettes','🦐'),
  -- Légumes
  ('Légumes','Salade','🥗'), ('Légumes','Tomate','🍅'), ('Légumes','Carotte','🥕'),
  ('Légumes','Courgette','🥒'), ('Légumes','Brocoli','🥦'), ('Légumes','Haricots verts','🫛'),
  ('Légumes','Épinards','🌿'), ('Légumes','Poivron','🫑'), ('Légumes','Champignons','🍄'),
  ('Légumes','Oignon','🧅'), ('Légumes','Concombre','🥒'), ('Légumes','Petits pois','🟢'),
  -- Fruits
  ('Fruits','Pomme','🍎'), ('Fruits','Banane','🍌'), ('Fruits','Orange','🍊'),
  ('Fruits','Fraises','🍓'), ('Fruits','Raisin','🍇'), ('Fruits','Kiwi','🥝'),
  ('Fruits','Poire','🍐'), ('Fruits','Pêche','🍑'), ('Fruits','Ananas','🍍'),
  ('Fruits','Myrtilles','🫐'), ('Fruits','Clémentine','🍊'),
  -- Produits laitiers
  ('Produits laitiers','Yaourt','🥛'), ('Produits laitiers','Fromage','🧀'),
  ('Produits laitiers','Lait','🥛'), ('Produits laitiers','Fromage blanc','🍶'),
  ('Produits laitiers','Beurre','🧈'), ('Produits laitiers','Crème fraîche','🥛'),
  -- Matières grasses
  ('Matières grasses','Huile d''olive','🫒'), ('Matières grasses','Avocat','🥑'),
  ('Matières grasses','Noix','🌰'), ('Matières grasses','Amandes','🥜'),
  ('Matières grasses','Beurre de cacahuète','🥜'),
  -- Plats préparés
  ('Plats préparés','Pizza','🍕'), ('Plats préparés','Burger','🍔'),
  ('Plats préparés','Sandwich','🥪'), ('Plats préparés','Sushi','🍱'),
  ('Plats préparés','Quiche','🥧'), ('Plats préparés','Soupe','🍲'),
  ('Plats préparés','Pâtes bolognaise','🍝'), ('Plats préparés','Tacos','🌮'),
  -- Encas & sucré
  ('Encas & sucré','Biscuits','🍪'), ('Encas & sucré','Chocolat','🍫'),
  ('Encas & sucré','Gâteau','🍰'), ('Encas & sucré','Chips','🥔'),
  ('Encas & sucré','Bonbons','🍬'), ('Encas & sucré','Viennoiserie','🥐'),
  ('Encas & sucré','Glace','🍦'), ('Encas & sucré','Barre céréalière','🍫')
) as p(cat, name, emoji)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ============================================================
--  FIN DU SCHÉMA
-- ============================================================
