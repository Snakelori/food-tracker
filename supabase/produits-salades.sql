-- ============================================================
--  FOOD TRACKER — Types de salades (catégorie Salades)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie « Salades »
insert into public.categories (name, emoji, sort_order)
select 'Salades', '🥗', 45
where not exists (select 1 from public.categories c where c.name = 'Salades');

-- Types de salades
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Salades composées / repas
  ('Salade César',            '🥗',160,8,3,10,10,0.9,250),
  ('Salade niçoise',          '🥗',120,6,3,7,8,0.8,300),
  ('Salade grecque',          '🥗',110,6,4,8,4,0.9,250),
  ('Salade de chèvre chaud',  '🧀',200,12,4,13,9,1,250),
  ('Salade landaise',         '🥗',180,6,3,13,11,1,300),
  ('Salade périgourdine',     '🦆',190,6,3,14,11,1,300),
  ('Salade composée',         '🥗',90,6,3,5,5,0.5,250),
  ('Salade caprese',          '🍅',200,4,3,16,11,0.8,200),
  ('Salade italienne',        '🥗',150,12,3,9,5,0.8,250),
  ('Salade Waldorf',          '🍏',200,12,8,15,3,0.4,200),
  ('Salade endives-noix',     '🌰',180,8,4,14,5,0.5,200),
  -- Salades avec protéines
  ('Salade de poulet',        '🍗',140,5,3,8,13,0.8,300),
  ('Salade de thon',          '🐟',130,6,3,7,12,0.9,300),
  ('Salade de crevettes',     '🦐',120,5,3,7,11,0.9,300),
  ('Salade de saumon fumé',   '🐟',170,4,2,12,12,1.2,250),
  -- Salades de féculents / légumineuses
  ('Salade de pâtes',         '🍝',180,22,3,8,5,0.7,250),
  ('Salade de riz',           '🍚',170,24,2,6,4,0.7,250),
  ('Salade de pommes de terre','🥔',160,15,2,10,3,0.6,200),
  ('Salade de quinoa',        '🌿',150,20,2,6,5,0.6,250),
  ('Salade de lentilles',     '🫘',140,18,2,5,8,0.6,250),
  -- Crudités / légumes
  ('Salade verte',            '🥬',20,2,1,0.5,1.4,0.3,80),
  ('Salade de tomates',       '🍅',40,4,3,2.5,1,0.4,150),
  ('Salade de concombre',     '🥒',40,3,2,3,0.7,0.4,150),
  ('Carottes râpées',         '🥕',90,9,6,5,1,0.4,120),
  ('Salade de betterave',     '🟣',90,10,8,4,1.5,0.4,120),
  ('Coleslaw',                '🥬',150,8,6,12,1.5,0.5,120),
  ('Salade de mâche',         '🌱',60,4,2,4,2,0.4,100)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Salades'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle : nb de salades chargées
select count(*) as nb_salades
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Salades' and pr.user_id is null;
