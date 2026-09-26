-- ============================================================
--  FOOD TRACKER — Tous les gâteaux (complément)
--  • « Pâtisseries & tartes » (nouvelle catégorie) : fraisier, opéra,
--    forêt-noire, saint-honoré, tartes aux fruits, galette des rois…
--  • « Gâteaux & goûter » (existante) : gâteaux maison, cakes,
--    gâteaux d'anniversaire, spécialités du monde…
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON (aucun nom déjà présent au catalogue) :
--  réexécutable sans risque.
-- ============================================================

-- Catégories
insert into public.categories (name, emoji, sort_order)
select 'Pâtisseries & tartes', '🥧', 96
where not exists (select 1 from public.categories c where c.name = 'Pâtisseries & tartes');

insert into public.categories (name, emoji, sort_order)
select 'Gâteaux & goûter', '🧁', 96
where not exists (select 1 from public.categories c where c.name = 'Gâteaux & goûter');

-- Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- ===== Pâtisseries françaises =====
  ('Pâtisseries & tartes','Fraisier',                    '🍓',290,35,25,14,5,0.2,120),
  ('Pâtisseries & tartes','Framboisier',                 '🫐',290,35,25,14,5,0.2,120),
  ('Pâtisseries & tartes','Opéra',                       '🍫',420,42,32,25,6,0.2,90),
  ('Pâtisseries & tartes','Forêt-noire',                 '🍒',300,32,24,17,5,0.2,120),
  ('Pâtisseries & tartes','Charlotte aux fraises',       '🍓',220,30,22,9,4,0.1,120),
  ('Pâtisseries & tartes','Charlotte aux poires',        '🍐',210,30,22,8,4,0.1,120),
  ('Pâtisseries & tartes','Charlotte au chocolat',       '🍫',300,30,25,18,5,0.1,120),
  ('Pâtisseries & tartes','Saint-Honoré',                '🥮',330,32,22,20,5,0.2,120),
  ('Pâtisseries & tartes','Religieuse au chocolat',      '🍫',280,32,20,14,6,0.3,110),
  ('Pâtisseries & tartes','Religieuse au café',          '☕',280,32,20,14,6,0.3,110),
  ('Pâtisseries & tartes','Éclair au café',              '☕',260,30,18,13,5,0.3,90),
  ('Pâtisseries & tartes','Éclair au caramel',           '🍮',270,32,20,13,5,0.4,90),
  ('Pâtisseries & tartes','Chou à la crème',             '🥮',270,25,15,16,6,0.3,80),
  ('Pâtisseries & tartes','Chou chantilly',              '🥮',330,25,15,23,5,0.2,80),
  ('Pâtisseries & tartes','Tarte tropézienne',           '🍰',350,40,20,18,7,0.3,120),
  ('Pâtisseries & tartes','Merveilleux',                 '☁️',450,45,40,28,4,0.1,60),
  ('Pâtisseries & tartes','Succès / dacquoise',          '🌰',420,40,32,26,8,0.1,80),
  ('Pâtisseries & tartes','Royal chocolat (trianon)',    '🍫',480,45,35,30,6,0.2,90),
  ('Pâtisseries & tartes','Entremets chocolat',          '🍫',330,32,26,20,5,0.1,100),
  ('Pâtisseries & tartes','Entremets aux fruits',        '🍓',230,30,24,10,4,0.1,100),
  ('Pâtisseries & tartes','Bavarois aux fruits',         '🍓',200,26,22,9,4,0.1,120),
  ('Pâtisseries & tartes','Mont-Blanc',                  '🌰',350,48,35,15,4,0.1,100),
  ('Pâtisseries & tartes','Pavlova',                     '🍓',250,40,35,9,3,0.1,120),
  ('Pâtisseries & tartes','Savarin',                     '🍰',280,42,28,9,4,0.2,120),
  ('Pâtisseries & tartes','Puits d''amour',              '🍮',330,40,22,16,6,0.2,90),
  ('Pâtisseries & tartes','Croquembouche',               '🥮',380,50,30,17,6,0.3,150),
  ('Pâtisseries & tartes','Galette des rois (frangipane)','👑',450,40,20,28,8,0.6,120),
  ('Pâtisseries & tartes','Bûche de Noël pâtissière',    '🎄',350,40,30,18,5,0.2,100),
  ('Pâtisseries & tartes','Bûche de Noël chocolat',      '🎄',380,40,32,22,5,0.2,100),
  ('Pâtisseries & tartes','Mille-crêpes',                '🥞',280,30,15,15,6,0.2,120),
  ('Pâtisseries & tartes','Bostock',                     '🥐',420,45,25,23,8,0.4,80),
  -- ===== Tartes =====
  ('Pâtisseries & tartes','Tarte aux pommes',            '🥧',240,32,16,11,3,0.3,120),
  ('Pâtisseries & tartes','Tarte normande',              '🍏',260,30,18,14,4,0.2,120),
  ('Pâtisseries & tartes','Tarte aux fraises',           '🍓',250,32,18,12,4,0.2,120),
  ('Pâtisseries & tartes','Tarte aux framboises',        '🫐',260,32,18,13,4,0.2,120),
  ('Pâtisseries & tartes','Tarte aux myrtilles',         '🫐',240,33,18,10,3,0.2,120),
  ('Pâtisseries & tartes','Tarte aux abricots',          '🍑',230,32,17,10,3,0.2,120),
  ('Pâtisseries & tartes','Tarte aux prunes / quetsches','🟣',220,30,15,9,3,0.2,120),
  ('Pâtisseries & tartes','Tarte aux mirabelles',        '🟡',225,31,16,9,3,0.2,120),
  ('Pâtisseries & tartes','Tarte à la rhubarbe',         '🥧',220,30,16,9,3,0.2,120),
  ('Pâtisseries & tartes','Tarte amandine aux poires',   '🍐',330,38,22,17,6,0.2,120),
  ('Pâtisseries & tartes','Tarte au citron meringuée',   '🍋',320,45,32,13,4,0.2,120),
  ('Pâtisseries & tartes','Tarte au chocolat',           '🍫',420,40,28,26,6,0.2,100),
  ('Pâtisseries & tartes','Tarte au sucre',              '🥧',400,55,30,18,6,0.4,100),
  ('Pâtisseries & tartes','Tarte au fromage blanc',      '🧀',230,24,15,11,8,0.3,120),
  ('Pâtisseries & tartes','Tarte aux noix',              '🌰',480,45,28,30,7,0.2,100),
  ('Pâtisseries & tartes','Tartelette aux fruits',       '🍓',260,34,20,12,4,0.2,90),
  ('Pâtisseries & tartes','Croustade aux pommes',        '🍏',300,40,22,14,3,0.3,120),
  ('Pâtisseries & tartes','Crumble aux pommes',          '🍏',230,33,20,10,3,0.2,150),
  ('Pâtisseries & tartes','Crumble fruits rouges',       '🍓',240,34,21,10,3,0.2,150),
  ('Pâtisseries & tartes','Strudel aux pommes',          '🍏',260,34,18,12,3,0.2,120),
  ('Pâtisseries & tartes','Tarte au potiron (pumpkin pie)','🎃',230,30,18,10,4,0.3,120),
  ('Pâtisseries & tartes','Tarte aux noix de pécan (pecan pie)','🌰',440,55,32,23,5,0.4,120),
  -- ===== Gâteaux maison & anniversaire =====
  ('Gâteaux & goûter','Gâteau d''anniversaire (crème au beurre)','🎂',400,50,38,20,4,0.3,120),
  ('Gâteaux & goûter','Gâteau d''anniversaire chocolat','🎂',400,48,36,21,5,0.3,120),
  ('Gâteaux & goûter','Layer cake',                     '🎂',380,48,36,19,4,0.4,120),
  ('Gâteaux & goûter','Number cake',                    '🎂',400,48,38,20,5,0.2,120),
  ('Gâteaux & goûter','Molly cake',                     '🎂',380,50,34,18,5,0.4,100),
  ('Gâteaux & goûter','Moelleux au chocolat',           '🍫',420,45,34,24,6,0.3,80),
  ('Gâteaux & goûter','Gâteau aux pommes',              '🍏',280,40,24,11,4,0.3,100),
  ('Gâteaux & goûter','Gâteau à l''orange',             '🍊',370,50,30,17,5,0.3,80),
  ('Gâteaux & goûter','Gâteau au citron',               '🍋',380,50,32,18,5,0.3,80),
  ('Gâteaux & goûter','Gâteau aux amandes',             '🌰',440,42,30,26,9,0.2,80),
  ('Gâteaux & goûter','Gâteau à la noix de coco',       '🥥',420,45,32,24,5,0.3,80),
  ('Gâteaux & goûter','Gâteau renversé à l''ananas',    '🍍',300,45,32,12,4,0.3,100),
  ('Gâteaux & goûter','Gâteau magique',                 '✨',250,30,20,12,6,0.2,100),
  ('Gâteaux & goûter','Gâteau nantais',                 '🍰',440,48,35,24,6,0.3,80),
  ('Gâteaux & goûter','Gâteau breton',                  '🧈',470,52,25,26,6,0.8,60),
  ('Gâteaux & goûter','Gâteau des rois (brioche)',      '👑',360,50,20,14,8,0.5,100),
  ('Gâteaux & goûter','Gâteau de riz',                  '🍚',150,25,15,4,4,0.1,120),
  ('Gâteaux & goûter','Gâteau de semoule',              '🍮',140,24,14,3,4,0.1,120),
  ('Gâteaux & goûter','Cake au citron',                 '🍋',390,52,32,18,5,0.4,50),
  ('Gâteaux & goûter','Cake au chocolat',               '🍫',410,50,32,21,6,0.4,50),
  ('Gâteaux & goûter','Banana bread',                   '🍌',330,50,25,12,5,0.5,80),
  ('Gâteaux & goûter','Carrot cake (gâteau aux carottes)','🥕',400,45,30,22,5,0.5,100),
  ('Gâteaux & goûter','Kouglof',                        '🍰',370,48,18,16,7,0.6,70),
  ('Gâteaux & goûter','Pain perdu',                     '🍞',250,30,14,11,8,0.5,120),
  ('Gâteaux & goûter','Fiadone (gâteau corse)',         '🧀',220,20,15,11,11,0.3,100),
  ('Gâteaux & goûter','Nonnette',                       '🍯',370,70,40,6,4,0.2,30),
  ('Gâteaux & goûter','Rocher coco',                    '🥥',450,50,40,25,4,0.1,30),
  -- ===== Gâteaux du monde =====
  ('Gâteaux & goûter','Cheesecake aux fruits rouges',   '🍓',300,30,22,18,6,0.4,120),
  ('Gâteaux & goûter','Red velvet',                     '❤️',380,48,36,19,4,0.4,120),
  ('Gâteaux & goûter','Sachertorte',                    '🍫',400,50,40,20,5,0.2,100),
  ('Gâteaux & goûter','Cupcake',                        '🧁',400,55,40,19,4,0.4,70),
  ('Gâteaux & goûter','Whoopie pie',                    '🍪',420,58,38,20,4,0.5,70),
  ('Gâteaux & goûter','Blondie',                        '🍪',450,55,40,23,5,0.3,70),
  ('Gâteaux & goûter','Pastéis de nata',                '🥧',300,35,18,15,5,0.3,60),
  ('Gâteaux & goûter','Tres leches',                    '🥛',280,38,30,11,6,0.2,120),
  ('Gâteaux & goûter','Panettone',                      '🎄',380,55,25,14,7,0.5,80),
  ('Gâteaux & goûter','Stollen',                        '🎄',400,58,30,16,6,0.4,70),
  ('Gâteaux & goûter','Lamington',                      '🥥',400,52,38,19,4,0.3,70),
  ('Gâteaux & goûter','Castella (gâteau japonais)',     '🍰',300,55,35,5,7,0.2,60),
  ('Gâteaux & goûter','Mochi',                          '🍡',250,55,25,1,4,0.02,40),
  ('Gâteaux & goûter','Dorayaki',                       '🥞',280,55,28,3,6,0.3,80),
  ('Gâteaux & goûter','Churros',                        '🥖',380,45,10,20,5,0.4,100)
) as p(cat, name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where lower(x.name) = lower(p.name) and x.user_id is null
);

-- Contrôle
select c.name as categorie, count(*) as nb_produits
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name in ('Pâtisseries & tartes', 'Gâteaux & goûter') and pr.user_id is null
group by c.name order by c.name;
