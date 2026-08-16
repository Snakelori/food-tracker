-- ============================================================
--  FOOD TRACKER — Macédoine (légumes & fruits)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Légumes
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Macédoine de légumes',              '🥕',55,9,3,0.5,2.5,0.4,130),
  ('Macédoine de légumes mayonnaise',   '🥗',150,8,3,12,2,0.6,130)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Légumes'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Fruits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Macédoine de fruits',               '🍓',70,16,15,0.1,0.5,0.01,130)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Fruits'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select name, (select name from public.categories c where c.id = pr.category_id) as categorie
from public.products pr
where pr.user_id is null and pr.name ilike 'macédoine%'
order by categorie, name;
