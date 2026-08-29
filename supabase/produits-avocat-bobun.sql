-- ============================================================
--  FOOD TRACKER — Avocats (préparations) & Bo bun
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g + portion type. Additif et SANS DOUBLON.
--  (Le kebab est déjà présent : voir produits-fastfood-kebab.sql.)
-- ============================================================

-- ---------- Avocats : plat simple ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Demi-avocat',        '🥑',160,9,1,15,2,0.01,100)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Matières grasses'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Avocado toast (Pain & céréales) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Avocado toast',      '🥑',220,18,2,14,5,0.6,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Pain & céréales'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Avocats en salade / entrée (Salades) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Avocat crevettes',   '🥑',160,4,2,12,9,0.6,150),
  ('Avocat vinaigrette', '🥑',200,4,1,18,2,0.4,150),
  ('Salade d''avocat',   '🥑',150,6,2,12,3,0.4,150)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Salades'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Bo bun (Plats préparés) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Bo bun (bœuf)',      '🍜',150,18,4,5,8,0.7,400),
  ('Bo bun poulet',      '🍜',145,18,4,4,9,0.7,400),
  ('Bo bun nems',        '🍜',170,20,4,7,7,0.8,400),
  ('Bo bun crevettes',   '🍜',140,18,4,4,8,0.8,400)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Plats préparés'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select pr.name, c.name as categorie
from public.products pr join public.categories c on c.id = pr.category_id
where pr.user_id is null and (pr.name ilike '%avocat%' or pr.name ilike 'avocado%' or pr.name ilike 'bo bun%')
order by categorie, pr.name;
