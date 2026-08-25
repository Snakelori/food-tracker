-- ============================================================
--  FOOD TRACKER — Tartares (viande, poisson, légumes)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g + portion type. Additif et SANS DOUBLON.
-- ============================================================

-- ---------- Viandes (Protéines) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Steak tartare (bœuf)',        '🥩',200,2,1,12,20,0.9,180),
  ('Tartare de bœuf',             '🥩',200,2,1,12,20,0.9,180),
  ('Tartare de bœuf aller-retour','🥩',210,2,1,13,20,0.9,180),
  ('Tartare de cheval',           '🐴',180,1,0,8,25,0.8,180),
  ('Tartare de veau',             '🥩',180,1,0,9,23,0.8,180)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Protéines'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Poissons & fruits de mer ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Tartare de saumon',           '🐟',200,1,1,13,18,0.7,150),
  ('Tartare de saumon-avocat',    '🥑',210,3,1,15,14,0.6,150),
  ('Tartare de thon',             '🐟',150,1,1,5,24,0.7,150),
  ('Tartare de dorade',           '🐟',120,1,0,4,20,0.6,150),
  ('Tartare de bar',              '🐟',120,1,0,4,20,0.6,150),
  ('Tartare de Saint-Jacques',    '🐚',120,2,1,4,18,0.7,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Poissons & fruits de mer'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Légumes ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Tartare d''avocat',           '🥑',180,6,1,16,2,0.4,120),
  ('Tartare de tomates',          '🍅',60,5,4,3,1,0.3,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Légumes'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select pr.name, c.name as categorie
from public.products pr join public.categories c on c.id = pr.category_id
where pr.user_id is null and (pr.name ilike 'tartare%' or pr.name ilike 'steak tartare%')
order by categorie, pr.name;
