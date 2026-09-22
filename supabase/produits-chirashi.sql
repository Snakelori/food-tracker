-- ============================================================
--  FOOD TRACKER — Chirashi (Restaurant japonais)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g + portion type (~1 bol). Additif et SANS DOUBLON.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Chirashi saumon',          '🍣',160,20,2,6,10,0.8,350),
  ('Chirashi thon',            '🍣',150,20,2,3,12,0.8,350),
  ('Chirashi mixte',           '🍣',160,20,2,5,11,0.9,350),
  ('Chirashi saumon-avocat',   '🥑',175,20,2,8,9,0.8,350),
  ('Chirashi crevettes',       '🦐',150,21,2,3,11,0.9,350),
  ('Chirashi végétarien',      '🥗',150,24,3,3,5,0.7,350)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Restaurant japonais'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select pr.name from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Restaurant japonais' and pr.user_id is null and pr.name ilike 'chirashi%'
order by pr.name;
