-- ============================================================
--  FOOD TRACKER — Viandes : boulettes, panés, morceaux, saucisses,
--  charcuterie (Protéines) + plats mijotés (Plats préparés)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après schema.sql + nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- ---------- Protéines : boulettes, panés, morceaux, charcuterie ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Boulettes
  ('Boulettes de viande',        '🍖',240,5,1,17,17,0.9,120),
  ('Boulettes de bœuf',          '🥩',240,5,1,17,17,0.9,120),
  ('Boulettes de veau',          '🥩',200,5,1,12,18,0.9,120),
  ('Boulettes d''agneau (kefta)','🐑',250,4,1,19,17,1,120),
  ('Boulettes de porc',          '🥓',250,5,1,19,16,1,120),
  ('Boulettes de volaille',      '🍗',190,6,1,11,18,0.9,120),
  ('Boulettes de poisson',       '🐟',150,8,1,7,14,0.8,100),
  ('Boulettes suédoises',        '🍖',260,8,2,19,15,1.1,120),
  -- Steak haché
  ('Steak haché 15% MG',         '🥩',250,0,0,15,20,0.2,125),
  ('Steak haché 5% MG',          '🥩',150,0,0,5,21,0.2,125),
  ('Steak végétal',              '🌱',180,6,1,9,17,1,100),
  -- Panés
  ('Cordon bleu (poulet)',       '🍗',240,15,1,13,16,1.1,120),
  ('Escalope milanaise',         '🍗',230,14,1,12,17,0.9,130),
  ('Escalope panée',             '🍗',220,14,1,11,17,0.9,130),
  ('Nuggets de poulet',          '🍗',250,16,1,15,14,1,100),
  ('Tenders / aiguillettes panées','🍗',240,16,1,13,16,1,100),
  -- Morceaux
  ('Blanc de poulet',            '🍗',165,0,0,3.6,31,0.2,120),
  ('Cuisse de poulet',           '🍗',200,0,0,12,21,0.3,150),
  ('Aile de poulet',             '🍗',220,0,0,15,20,0.3,100),
  ('Escalope de dinde',          '🦃',130,0,0,2,27,0.2,120),
  ('Escalope de veau',           '🥩',150,0,0,4,27,0.2,120),
  ('Côte de porc',               '🥓',240,0,0,16,22,0.2,150),
  ('Côte d''agneau',             '🐑',280,0,0,22,20,0.2,120),
  ('Entrecôte',                  '🥩',260,0,0,20,20,0.2,150),
  ('Steak / bavette',            '🥩',190,0,0,9,26,0.2,150),
  ('Magret de canard',           '🦆',250,0,0,18,22,0.2,150),
  ('Travers de porc',            '🥓',290,1,1,24,18,0.6,150),
  -- Saucisses
  ('Saucisse',                   '🌭',300,1,1,26,15,1.8,80),
  ('Chipolata',                  '🌭',290,1,1,25,15,1.8,60),
  ('Saucisse de Toulouse',       '🌭',300,1,0,26,15,1.8,100),
  ('Merguez',                    '🌭',280,2,1,23,16,1.8,60),
  ('Saucisse de Strasbourg (knacki)','🌭',270,2,1,24,12,2,50),
  ('Saucisse de volaille',       '🌭',200,2,1,14,16,1.5,80),
  ('Boudin noir',                '⚫',380,1,1,35,14,1.5,100),
  ('Boudin blanc',               '⚪',300,3,1,26,13,1.4,100),
  ('Andouillette',               '🌭',280,1,0,24,15,1.5,120),
  ('Chorizo frais (à cuire)',    '🌶️',350,1,1,30,18,2,60),
  -- Charcuterie tranchée
  ('Jambon cru',                 '🍖',240,0,0,14,28,4.5,40),
  ('Bacon',                      '🥓',250,1,0,18,20,2.5,30),
  ('Lardons',                    '🥓',300,1,0,28,13,2,40),
  ('Chorizo sec',                '🌶️',450,2,1,38,24,3.5,30),
  ('Salami',                     '🍖',400,1,1,34,22,3.5,30),
  ('Mortadelle',                 '🍖',300,2,1,25,16,2.5,40),
  ('Pâté de campagne',           '🥫',300,2,1,26,13,1.6,50),
  ('Rillettes',                  '🥫',400,0,0,40,12,1.2,40)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Protéines'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Plats préparés : mijotés à base de viande ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Boulettes sauce tomate',     '🍝',150,7,4,9,10,0.8,250),
  ('Bœuf bourguignon',           '🍲',160,5,2,9,15,0.9,250),
  ('Blanquette de veau',         '🍲',150,6,2,8,13,0.8,250),
  ('Pot-au-feu',                 '🍲',110,6,3,4,13,0.8,300),
  ('Chili con carne',            '🌶️',130,12,3,5,9,0.7,250),
  ('Lasagnes',                   '🍝',150,13,4,7,8,0.7,250),
  ('Curry de bœuf',              '🍛',160,8,3,9,14,0.8,250),
  ('Poulet basquaise',           '🍲',130,6,3,6,15,0.8,250)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Plats préparés'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select 'Protéines' as categorie, count(*) as nb from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Protéines' and pr.user_id is null
union all
select 'Plats préparés', count(*) from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Plats préparés' and pr.user_id is null;
