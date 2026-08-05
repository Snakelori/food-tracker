-- ============================================================
--  FOOD TRACKER — Catégorie Poissons & fruits de mer (panés et non panés)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après schema.sql + nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie
insert into public.categories (name, emoji, sort_order)
select 'Poissons & fruits de mer', '🐟', 33
where not exists (select 1 from public.categories c where c.name = 'Poissons & fruits de mer');

-- Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Poissons non panés (frais / cuits)
  ('Saumon',                      '🐟',200,0,0,13,20,0.1,130),
  ('Pavé de saumon',              '🐟',200,0,0,13,20,0.1,150),
  ('Truite',                      '🐟',140,0,0,6,20,0.1,130),
  ('Cabillaud',                   '🐟',80,0,0,0.7,18,0.2,130),
  ('Colin / lieu',                '🐟',90,0,0,1,19,0.2,130),
  ('Merlu',                       '🐟',85,0,0,1,18,0.2,130),
  ('Merlan',                      '🐟',90,0,0,1,18,0.2,130),
  ('Églefin',                     '🐟',80,0,0,0.5,18,0.2,130),
  ('Lieu noir',                   '🐟',90,0,0,1,19,0.2,130),
  ('Thon (frais)',                '🐟',130,0,0,1,28,0.1,120),
  ('Thon en boîte (au naturel)',  '🥫',110,0,0,1,26,0.5,80),
  ('Sardine',                     '🐟',200,0,0,11,25,0.6,90),
  ('Sardines à l''huile',         '🥫',220,0,0,14,25,1,80),
  ('Maquereau',                   '🐟',205,0,0,14,19,0.3,120),
  ('Hareng',                      '🐟',210,0,0,15,18,1.5,120),
  ('Dorade',                      '🐟',100,0,0,3,18,0.2,130),
  ('Bar (loup)',                  '🐟',100,0,0,2,20,0.2,130),
  ('Sole',                        '🐟',85,0,0,1.5,17,0.3,130),
  ('Limande',                     '🐟',85,0,0,1.5,17,0.3,130),
  ('Flétan',                      '🐟',110,0,0,2,21,0.2,130),
  ('Espadon',                     '🐟',145,0,0,6,20,0.2,130),
  ('Rouget',                      '🐟',115,0,0,4,19,0.2,120),
  ('Turbot',                      '🐟',95,0,0,2,17,0.2,130),
  ('Raie',                        '🐟',90,0,0,1,20,0.3,130),
  ('Lotte',                       '🐟',80,0,0,1,17,0.3,130),
  ('Anchois',                     '🐟',130,0,0,5,20,0.5,80),
  ('Saumon fumé',                 '🐟',180,0,0,11,22,3,60),
  ('Truite fumée',                '🐟',160,0,0,8,22,2.5,60),
  ('Haddock (fumé)',              '🐟',100,0,0,0.5,23,2.5,120),
  ('Brandade de morue',           '🐟',180,10,1,11,10,1,150),
  -- Poissons panés
  ('Poisson pané',                '🍤',220,15,1,11,14,0.8,100),
  ('Cabillaud pané',              '🍤',200,15,1,9,14,0.8,100),
  ('Colin pané',                  '🍤',210,15,1,10,14,0.8,100),
  ('Bâtonnets de poisson',        '🍤',230,18,1,12,12,0.9,90),
  ('Croquettes de poisson',       '🍤',220,17,1,11,12,0.9,100),
  ('Nuggets de poisson',          '🍤',240,18,1,13,13,0.9,100),
  ('Cordon bleu de poisson',      '🍤',230,16,1,12,14,1,110),
  ('Beignets de poisson',         '🍤',250,18,1,15,12,0.8,100),
  ('Fish & chips',                '🍟',250,20,1,14,13,0.8,150),
  ('Escalope de saumon panée',    '🍤',230,14,1,13,16,0.8,120),
  ('Calamars panés (rings)',      '🍤',200,18,1,9,10,1,100),
  ('Crevettes panées / tempura',  '🍤',240,20,1,12,12,1,100),
  ('Gambas panées',               '🍤',240,20,1,12,12,1,100),
  -- Fruits de mer
  ('Crevettes',                   '🦐',100,0,0,1,20,1,80),
  ('Gambas',                      '🦐',100,0,0,1,20,1,90),
  ('Moules',                      '🦪',85,4,0,2,12,0.5,150),
  ('Huîtres',                     '🦪',70,4,0,2,9,1.5,100),
  ('Coquilles Saint-Jacques',     '🐚',90,4,0,1,17,0.8,90),
  ('Calamars / encornets',        '🦑',90,3,0,1.5,16,0.6,100),
  ('Poulpe',                      '🐙',100,4,0,1,18,0.5,100),
  ('Seiche',                      '🦑',90,1,0,1,16,0.6,100),
  ('Crabe',                       '🦀',85,0,0,1,18,0.7,100),
  ('Tourteau',                    '🦀',85,0,0,1,18,0.7,100),
  ('Homard',                      '🦞',90,0,0,1,19,0.5,150),
  ('Langoustines',                '🦐',90,0,0,1,18,0.6,100),
  ('Langouste',                   '🦞',90,0,0,1,19,0.5,150),
  ('Bulots',                      '🐚',130,8,0,0.4,24,1,80),
  ('Bigorneaux',                  '🐚',100,6,0,1,17,1,50),
  ('Palourdes',                   '🐚',75,2,0,1,14,1,100),
  ('Surimi',                      '🦀',100,12,3,1,8,2,80)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Poissons & fruits de mer'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_poissons_fruits_de_mer
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Poissons & fruits de mer' and pr.user_id is null;
