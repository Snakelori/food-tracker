-- ============================================================
--  FOOD TRACKER — Catégorie Gâteaux & goûter
--  (madeleines, quatre-quarts, financiers, cakes, marbré…)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie
insert into public.categories (name, emoji, sort_order)
select 'Gâteaux & goûter', '🧁', 96
where not exists (select 1 from public.categories c where c.name = 'Gâteaux & goûter');

-- Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Madeleines
  ('Madeleine nature',           '🧁',440,50,28,24,6,0.5,25),
  ('Madeleine au chocolat',      '🍫',450,52,32,24,6,0.5,25),
  ('Madeleine pépites chocolat', '🍫',455,52,33,24,6,0.5,25),
  ('Madeleine au citron',        '🍋',435,52,30,22,6,0.5,25),
  ('Madeleine au miel',          '🍯',445,54,32,22,6,0.5,25),
  ('Madeleine cœur chocolat',    '🍫',465,54,35,25,6,0.5,30),
  -- Quatre-quarts
  ('Quatre-quarts nature',       '🍰',430,50,28,22,6,0.5,60),
  ('Quatre-quarts breton',       '🍰',450,50,28,25,6,0.6,60),
  ('Quatre-quarts aux pommes',   '🍏',380,48,26,18,5,0.5,70),
  ('Quatre-quarts marbré',       '🍫',430,52,32,21,6,0.5,60),
  -- Cakes & gâteaux moelleux
  ('Marbré chocolat-vanille',    '🍫',430,52,32,21,6,0.5,40),
  ('Cake nature',                '🍰',400,50,26,19,6,0.5,50),
  ('Cake aux fruits',            '🍇',380,55,32,14,5,0.4,50),
  ('Gâteau au yaourt',           '🍰',350,48,26,15,6,0.4,60),
  ('Gâteau au chocolat',         '🍫',400,45,32,22,6,0.4,70),
  ('Fondant au chocolat',        '🍫',380,45,35,20,5,0.3,80),
  ('Financier',                  '🧈',470,45,30,28,8,0.4,30),
  ('Génoise',                    '🍰',300,50,30,8,7,0.3,50),
  ('Gâteau roulé (confiture)',   '🍓',350,58,38,10,5,0.3,40),
  ('Gâteau de Savoie',           '🍰',300,55,32,6,8,0.3,50),
  ('Pain de Gênes',              '🌰',420,42,30,25,8,0.4,40),
  -- Spécialités régionales
  ('Gâteau basque',              '🍮',400,48,26,20,6,0.4,70),
  ('Kouign-amann',               '🧈',460,50,28,26,5,0.6,60),
  ('Far breton',                 '🍮',200,32,22,5,6,0.3,100),
  ('Clafoutis',                  '🍒',180,25,20,6,5,0.2,120),
  ('Cannelé',                    '🍮',340,55,35,10,6,0.3,40),
  ('Pain d''épices',             '🍯',350,70,45,5,5,0.6,30),
  -- Biscuits & feuilletés du goûter
  ('Palmier',                    '🌴',500,55,25,28,6,0.5,30),
  ('Chausson aux pommes',        '🍏',320,40,15,16,4,0.5,90),
  ('Sablé',                      '🍪',490,62,25,24,6,0.5,15),
  ('Petit-beurre',               '🍪',440,72,22,13,8,0.9,8),
  ('Tuile aux amandes',          '🥜',500,55,40,28,8,0.2,10)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Gâteaux & goûter'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_gateaux
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Gâteaux & goûter' and pr.user_id is null;
