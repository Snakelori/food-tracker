-- ============================================================
--  FOOD TRACKER — Salades japonaises (Restaurant japonais)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g + portion type. Additif et SANS DOUBLON.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Salade japonaise (sésame-gingembre)', '🥗',80,6,3,5,2,0.6,150),
  ('Salade d''algues (wakamé)',           '🌿',90,6,4,5,2,1.2,100),
  ('Salade de chou japonaise',            '🥬',60,7,4,3,1.5,0.5,120),
  ('Salade de concombre (sunomono)',      '🥒',40,6,5,1,1,0.6,120),
  ('Salade d''edamame',                   '🫛',130,9,2,6,11,0.8,100),
  ('Salade de poulpe (tako su)',          '🐙',70,4,2,2,10,0.8,120),
  ('Salade de chou au sésame',            '🥬',90,7,4,6,2,0.5,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Restaurant japonais'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select pr.name from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Restaurant japonais' and pr.user_id is null and pr.name ilike 'salade%'
order by pr.name;
