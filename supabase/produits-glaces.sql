-- ============================================================
--  FOOD TRACKER — Catégorie Glaces & desserts glacés
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie
insert into public.categories (name, emoji, sort_order)
select 'Glaces & desserts glacés', '🍦', 97
where not exists (select 1 from public.categories c where c.name = 'Glaces & desserts glacés');

-- Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Boules / parfums (crème glacée)
  ('Glace vanille',              '🍦',200,24,21,11,3.5,0.12,100),
  ('Glace chocolat',            '🍫',216,28,24,11,3.8,0.15,100),
  ('Glace fraise',              '🍓',190,24,22,9,3,0.1,100),
  ('Glace pistache',            '🥜',230,23,20,14,4,0.1,100),
  ('Glace café',                '☕',200,24,22,10,3.5,0.1,100),
  ('Glace caramel beurre salé', '🍮',230,30,26,11,3,0.3,100),
  ('Glace stracciatella',       '🍦',220,24,22,13,3.5,0.12,100),
  ('Glace cookies',             '🍪',250,30,24,13,3.5,0.2,100),
  ('Glace cookie dough',        '🍪',255,31,25,13,3.5,0.2,100),
  ('Glace menthe-chocolat',     '🌿',220,26,23,12,3.5,0.12,100),
  ('Glace rhum-raisin',         '🍇',210,26,23,10,3,0.1,100),
  ('Glace praliné / noisette',  '🌰',240,25,22,14,4,0.1,100),
  ('Glace spéculoos',           '🍪',240,29,23,13,3.5,0.2,100),
  ('Glace coco',                '🥥',230,25,22,13,2.5,0.1,100),
  ('Glace vanille-caramel',     '🍦',220,28,24,11,3,0.2,100),
  ('Glace chocolat blanc',      '🤍',230,27,26,13,3.5,0.15,100),
  -- Sorbets (plein fruit)
  ('Sorbet citron',             '🍋',120,30,28,0,0.2,0.01,100),
  ('Sorbet fraise',             '🍓',110,27,25,0.1,0.4,0.01,100),
  ('Sorbet framboise',          '🫐',110,27,24,0.2,0.5,0.01,100),
  ('Sorbet mangue',             '🥭',120,29,27,0.1,0.4,0.01,100),
  ('Sorbet cassis',             '🫐',120,29,27,0.1,0.5,0.01,100),
  ('Sorbet poire',              '🍐',115,28,26,0.1,0.3,0.01,100),
  ('Sorbet abricot',            '🍑',115,28,26,0.1,0.4,0.01,100),
  ('Sorbet fruits de la passion','🌺',120,29,27,0.1,0.5,0.01,100),
  ('Sorbet coco',               '🥥',150,26,24,5,0.6,0.02,100),
  -- Desserts glacés
  ('Cornet de glace',           '🍦',250,32,22,12,3.5,0.2,110),
  ('Glace à l''italienne',      '🍦',200,30,24,7,4,0.15,150),
  ('Bâtonnet enrobé chocolat',  '🍫',316,30,27,20,4,0.15,79),
  ('Esquimau vanille',          '🍦',250,25,22,15,3,0.1,60),
  ('Glace à l''eau (bâtonnet)', '🧊',80,20,18,0,0,0.01,60),
  ('Glace tube (type Calippo)', '🧊',90,22,20,0,0,0.01,80),
  ('Coupe glacée',              '🍨',220,26,22,12,3.5,0.15,150),
  ('Banana split',             '🍌',200,26,22,10,3,0.1,250),
  ('Profiteroles glacées',      '🍫',280,28,20,17,5,0.3,150),
  ('Café liégeois',             '☕',200,24,21,11,3,0.1,150),
  ('Chocolat liégeois',         '🍫',210,26,23,11,3.5,0.12,150),
  ('Dame blanche',              '🍨',240,26,22,14,4,0.15,180),
  ('Vacherin glacé',            '🍰',250,32,26,12,3.5,0.15,100),
  ('Omelette norvégienne',      '🔥',230,32,26,10,4,0.2,120),
  ('Tranche napolitaine',       '🍦',210,25,22,11,3.5,0.12,75),
  ('Bûche glacée',              '🎄',240,28,24,13,3.5,0.15,100),
  ('Frozen yogurt',             '🍦',130,24,20,2,4,0.1,120),
  ('Granité',                   '🧊',90,22,20,0,0.1,0.01,150)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Glaces & desserts glacés'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_glaces
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Glaces & desserts glacés' and pr.user_id is null;
