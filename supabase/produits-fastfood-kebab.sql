-- ============================================================
--  FOOD TRACKER — Menus fast-food & kebabs
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après produits-restaurant-2.sql qui crée les catégories.)
--  Valeurs pour 100 g + portion type (poids d'un menu/sandwich).
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- ---------- Burger & Fast-food ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Burgers connus
  ('Big Mac',                    '🍔',256,21,4,13,11.6,1.07,215),
  ('Whopper',                    '🍔',233,18,4,13,10.4,0.8,270),
  ('Royal Cheese / Quarter',     '🍔',260,21,5,13,15,1.25,200),
  ('Double cheeseburger',        '🍔',267,21,4,13,15,1.2,165),
  ('Triple cheeseburger',        '🍔',260,17,3.5,14.5,15.5,1.2,200),
  ('Filet-O-Fish',               '🍔',271,27,3.6,13,11.4,0.86,140),
  ('McChicken',                  '🍔',250,25,3,12.5,9.4,0.94,160),
  ('Zinger burger',              '🍔',250,23,3,12,12,1,180),
  ('Giant / Master burger',      '🍔',255,18,4,14,14,1.2,250),
  -- Poulet
  ('Nuggets (x6)',               '🍗',260,16,0,16,14,1.1,100),
  ('Nuggets (x9)',               '🍗',260,16,0,16,14,1.07,150),
  ('Chicken wings épicées (x5)', '🍗',267,7,0.7,17,18.7,1.3,150),
  ('Poulet frit (1 pièce)',      '🍗',255,7,0,15,20,1.1,110),
  -- Wraps & autres
  ('Tacos français (poulet)',    '🌯',257,23,1.7,13,10,0.86,350),
  ('Croque McDo',                '🥪',250,25,3,11,11,1.2,100),
  -- Accompagnements
  ('Frites (moyenne)',           '🍟',287,37,0.4,14,3.5,0.4,115),
  ('Frites (grande)',            '🍟',293,37,0.4,14,3.3,0.47,150),
  ('Potatoes',                   '🥔',227,27,0.9,12,2.7,0.7,110),
  -- Desserts fast-food
  ('Sundae caramel',             '🍨',165,26,23.5,4.7,3,0.18,170),
  ('McFlurry',                   '🍨',189,30.5,25,5.5,3.3,0.17,180),
  ('Donut',                      '🍩',417,50,23,21,6.7,0.8,60),
  ('Muffin',                     '🧁',400,50,30,20,5,0.6,100),
  ('Cookie',                     '🍪',467,62,40,22,5.5,0.7,45),
  ('Chausson aux pommes',        '🥧',300,37,16,15,2.5,0.6,80)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Burger & Fast-food'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Kebabs (Libanais / Oriental) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Kebab (sandwich pain)',      '🥙',200,17,1.7,10,8.6,0.86,350),
  ('Kebab galette (dürüm)',      '🌯',197,17,1.6,10,8.4,0.84,380),
  ('Kebab poulet',               '🥙',194,17,1.7,9.1,9.1,0.86,350),
  ('Assiette kebab (+ frites)',  '🍽️',200,18,1.1,10,8.9,0.78,450),
  ('Kebab frites (sandwich)',    '🥙',215,20,1.4,11,8,0.9,420),
  ('Adana kebab',                '🍢',233,2,0.7,17,16.7,1,150),
  ('Iskender kebab',             '🍽️',200,13,2,11.7,9.3,0.67,300)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Libanais / Oriental'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select 'Burger & Fast-food' as categorie, count(*) as nb from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Burger & Fast-food' and pr.user_id is null
union all
select 'Libanais / Oriental', count(*) from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Libanais / Oriental' and pr.user_id is null;
