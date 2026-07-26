-- ============================================================
--  FOOD TRACKER — Produits « restaurant » : Pizzas & Japonais
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (À lancer APRÈS nutrition.sql, dont dépendent les colonnes.)
--
--  Valeurs POUR 100 g (moyennes de référence) + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- 1) Deux nouvelles catégories
insert into public.categories (name, emoji, sort_order)
select v.name, v.emoji, v.sort_order
from (values
  ('Pizzas',              '🍕', 85),
  ('Restaurant japonais', '🍣', 86)
) as v(name, emoji, sort_order)
where not exists (select 1 from public.categories c where c.name = v.name);

-- 2) Produits avec valeurs nutritionnelles
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- ---------------- Pizzas (portion = pizza entière ~350 g) ----------------
  ('Pizzas','Pizza Margherita','🍕',240,28,3,9,10,1.2,350),
  ('Pizzas','Pizza Reine','🍕',250,27,3,10,12,1.3,350),
  ('Pizzas','Pizza Regina','🍕',250,27,3,10,12,1.3,350),
  ('Pizzas','Pizza 4 fromages','🧀',290,26,3,15,14,1.5,350),
  ('Pizzas','Pizza Napolitaine','🍕',230,28,3,8,10,1.6,350),
  ('Pizzas','Pizza Calzone','🥟',260,28,3,11,13,1.4,350),
  ('Pizzas','Pizza Diavola (piquante)','🌶️',280,27,3,14,13,1.6,350),
  ('Pizzas','Pizza Pepperoni','🍕',285,27,3,14,13,1.6,350),
  ('Pizzas','Pizza Végétarienne','🥦',210,28,4,7,8,1.1,350),
  ('Pizzas','Pizza Chèvre-miel','🍯',270,30,8,12,11,1.3,350),
  ('Pizzas','Pizza Hawaïenne','🍍',240,30,6,9,11,1.3,350),
  ('Pizzas','Pizza Bolognaise','🍖',260,27,3,12,13,1.4,350),
  ('Pizzas','Pizza Saumon','🐟',235,27,3,9,12,1.3,350),
  ('Pizzas','Pizza Fruits de mer','🦐',225,27,3,8,12,1.4,350),
  ('Pizzas','Pizza Orientale (merguez)','🌶️',270,27,3,13,12,1.5,350),
  ('Pizzas','Pizza Savoyarde','🥔',290,28,3,15,11,1.5,350),
  ('Pizzas','Pizza Chorizo','🌶️',290,27,3,15,13,1.7,350),

  -- ---------------- Restaurant japonais ----------------
  -- Sushi / makis (portion = 1 pièce)
  ('Restaurant japonais','Sushi saumon (nigiri)','🍣',150,20,1,4,7,0.5,30),
  ('Restaurant japonais','Sushi thon (nigiri)','🍣',130,20,1,1,8,0.5,30),
  ('Restaurant japonais','Sushi crevette (nigiri)','🍤',130,21,1,1,7,0.5,30),
  ('Restaurant japonais','Maki saumon','🍥',145,24,1,3,5,0.6,20),
  ('Restaurant japonais','Maki thon','🍥',140,24,1,2,6,0.6,20),
  ('Restaurant japonais','Maki concombre','🥒',120,26,1,0.5,3,0.5,20),
  ('Restaurant japonais','Maki avocat','🥑',150,24,1,5,3,0.5,22),
  ('Restaurant japonais','California roll','🍙',170,26,3,5,4,0.6,25),
  ('Restaurant japonais','Spring roll','🥬',120,18,3,2,4,0.6,60),
  -- Sashimi (portion ~60 g)
  ('Restaurant japonais','Sashimi saumon','🐟',180,0,0,11,20,0.1,60),
  ('Restaurant japonais','Sashimi thon','🐟',130,0,0,1,28,0.1,60),
  -- Bols / plats
  ('Restaurant japonais','Chirashi','🍚',150,22,3,3,9,0.7,350),
  ('Restaurant japonais','Poké bowl japonais','🥗',150,18,4,5,9,0.7,350),
  ('Restaurant japonais','Ramen (bol)','🍜',90,12,1,3,5,1,450),
  ('Restaurant japonais','Udon (bol)','🍜',110,20,1,2,5,1,400),
  ('Restaurant japonais','Soba','🍜',100,20,0.5,1,5,0.8,350),
  ('Restaurant japonais','Donburi poulet','🍗',150,22,3,4,10,0.9,350),
  -- Accompagnements / brochettes / fritures
  ('Restaurant japonais','Gyoza','🥟',210,22,2,10,8,1,22),
  ('Restaurant japonais','Tempura crevette','🍤',240,18,1,14,10,0.8,30),
  ('Restaurant japonais','Tempura légumes','🍆',200,22,2,11,4,0.6,30),
  ('Restaurant japonais','Yakitori poulet','🍢',200,6,4,9,22,1.2,40),
  ('Restaurant japonais','Brochette bœuf-fromage','🥩',250,5,3,16,18,1.2,40),
  ('Restaurant japonais','Anguille (unagi)','🍣',230,8,6,14,19,1.2,60),
  ('Restaurant japonais','Poulpe (tako)','🐙',100,2,0,1,20,0.5,60),
  ('Restaurant japonais','Soupe miso','🍲',40,4,1,1.5,3,1.2,200),
  ('Restaurant japonais','Edamame','🫛',120,9,2,5,11,0.5,80),
  ('Restaurant japonais','Riz vinaigré','🍚',140,30,3,0.3,2.5,0.4,150),
  ('Restaurant japonais','Salade de chou','🥬',60,6,4,3,1,0.4,100),
  -- Dessert
  ('Restaurant japonais','Mochi','🍡',220,50,20,1,2,0.05,40)
) as p(cat, name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- 3) Contrôle : nb de produits ajoutés par catégorie
select c.name as categorie, count(pr.id) as nb_produits
from public.categories c
left join public.products pr on pr.category_id = c.id and pr.user_id is null
where c.name in ('Pizzas','Restaurant japonais')
group by c.name;
