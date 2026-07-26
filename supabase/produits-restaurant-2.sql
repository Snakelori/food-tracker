-- ============================================================
--  FOOD TRACKER — Restaurants (Italien, Burger, Chinois, Thaï,
--  Indien, Mexicain, Libanais) + Desserts classiques
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- 1) Nouvelles catégories
insert into public.categories (name, emoji, sort_order)
select v.name, v.emoji, v.sort_order
from (values
  ('Italien',              '🍝', 82),
  ('Burger & Fast-food',   '🍔', 83),
  ('Chinois',              '🥡', 87),
  ('Thaïlandais',          '🍲', 88),
  ('Indien',               '🍛', 89),
  ('Mexicain',             '🌮', 91),
  ('Libanais / Oriental',  '🧆', 92),
  ('Desserts',             '🍰', 95)
) as v(name, emoji, sort_order)
where not exists (select 1 from public.categories c where c.name = v.name);

-- 2) Produits avec valeurs nutritionnelles
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- ---------------- Italien ----------------
  ('Italien','Spaghetti carbonara','🍝',200,22,2,9,8,0.8,350),
  ('Italien','Spaghetti bolognaise','🍝',150,18,3,5,7,0.6,350),
  ('Italien','Penne arrabbiata','🍝',150,25,4,3,5,0.6,350),
  ('Italien','Tagliatelles au saumon','🍝',180,20,2,8,8,0.7,350),
  ('Italien','Pâtes au pesto','🌿',250,28,2,12,8,0.7,350),
  ('Italien','Risotto aux champignons','🍚',150,20,1,5,4,0.7,300),
  ('Italien','Gnocchi gorgonzola','🥟',200,25,2,9,6,0.9,300),
  ('Italien','Ravioli ricotta-épinards','🥟',170,22,2,6,7,0.8,300),
  ('Italien','Escalope milanaise','🍗',240,14,1,13,18,1,200),
  ('Italien','Osso buco','🍖',180,5,2,9,18,0.8,250),
  ('Italien','Aubergines parmigiana','🍆',130,8,4,8,5,0.7,250),
  ('Italien','Bruschetta','🍅',180,24,3,7,5,0.9,100),
  ('Italien','Antipasti','🫒',200,8,3,15,8,1.2,150),
  -- ---------------- Burger & Fast-food ----------------
  ('Burger & Fast-food','Hamburger','🍔',250,22,5,11,13,1.1,180),
  ('Burger & Fast-food','Cheeseburger','🍔',260,22,5,13,14,1.3,200),
  ('Burger & Fast-food','Double burger','🍔',280,20,5,16,16,1.4,280),
  ('Burger & Fast-food','Bacon burger','🥓',290,20,5,17,16,1.5,250),
  ('Burger & Fast-food','Chicken burger','🍗',250,24,4,11,14,1.2,220),
  ('Burger & Fast-food','Fish burger','🐟',260,26,4,12,11,1.1,180),
  ('Burger & Fast-food','Veggie burger','🥦',220,25,5,8,9,1,200),
  ('Burger & Fast-food','Hot-dog','🌭',250,20,4,15,9,1.4,150),
  ('Burger & Fast-food','Wrap poulet','🌯',230,26,3,8,11,1.1,220),
  ('Burger & Fast-food','Tenders de poulet','🍗',260,16,1,14,18,1.2,120),
  ('Burger & Fast-food','Onion rings','🧅',330,35,4,18,4,1,100),
  ('Burger & Fast-food','Salade César','🥗',160,8,3,10,10,0.9,250),
  ('Burger & Fast-food','Milkshake','🥤',110,18,16,3,3,0.2,300),
  -- ---------------- Chinois ----------------
  ('Chinois','Nouilles sautées','🍜',160,22,2,6,5,1,300),
  ('Chinois','Riz cantonais','🍚',170,25,2,5,6,0.9,250),
  ('Chinois','Poulet aigre-doux','🍗',190,22,15,7,10,0.9,250),
  ('Chinois','Bœuf aux oignons','🥩',160,8,4,9,14,1,250),
  ('Chinois','Porc au caramel','🥓',220,15,12,12,14,1.1,250),
  ('Chinois','Canard laqué','🦆',240,6,4,15,19,1,150),
  ('Chinois','Poulet aux noix de cajou','🥜',200,14,6,11,12,1,250),
  ('Chinois','Raviolis vapeur','🥟',200,24,2,8,8,1,30),
  ('Chinois','Beignets de crevette','🍤',240,20,2,14,9,0.9,30),
  ('Chinois','Soupe won-ton','🍲',60,7,1,2,4,1,250),
  -- ---------------- Thaïlandais ----------------
  ('Thaïlandais','Curry vert thaï','🍲',130,8,4,9,7,0.9,300),
  ('Thaïlandais','Curry rouge thaï','🌶️',140,9,5,9,7,0.9,300),
  ('Thaïlandais','Poulet basilic thaï','🌿',170,8,4,9,14,1,250),
  ('Thaïlandais','Riz sauté thaï','🍚',170,25,3,5,5,0.9,300),
  ('Thaïlandais','Nouilles sautées (pad see ew)','🍜',180,24,4,6,6,1,300),
  ('Thaïlandais','Soupe tom yum','🍲',60,6,2,2,5,1.1,250),
  ('Thaïlandais','Salade de papaye (som tam)','🥗',80,14,8,2,2,0.7,150),
  ('Thaïlandais','Satay de poulet','🍢',220,6,4,12,20,1,100),
  -- ---------------- Indien ----------------
  ('Indien','Poulet tikka masala','🍛',160,8,4,9,12,0.9,300),
  ('Indien','Poulet tandoori','🍗',150,4,2,6,22,1,200),
  ('Indien','Butter chicken','🍛',190,8,5,12,13,0.9,300),
  ('Indien','Curry d''agneau','🍛',180,6,3,11,15,0.9,300),
  ('Indien','Poulet korma','🍛',200,9,5,13,12,0.9,300),
  ('Indien','Palak paneer','🧀',170,6,3,12,8,0.8,250),
  ('Indien','Dahl de lentilles','🫘',120,16,2,4,6,0.6,250),
  ('Indien','Biryani','🍚',180,26,2,6,6,0.8,300),
  ('Indien','Naan','🫓',310,50,3,8,9,1,90),
  ('Indien','Naan au fromage','🧀',330,45,3,12,11,1.1,100),
  ('Indien','Pakora','🧅',280,25,2,17,6,0.9,60),
  -- ---------------- Mexicain ----------------
  ('Mexicain','Burrito','🌯',200,25,3,7,9,1,300),
  ('Mexicain','Quesadilla','🫓',280,26,3,15,12,1.2,200),
  ('Mexicain','Fajitas','🌮',180,18,3,8,11,1,300),
  ('Mexicain','Enchiladas','🌮',200,20,4,9,10,1.1,300),
  ('Mexicain','Taco al pastor','🌮',220,20,3,10,12,1,150),
  ('Mexicain','Nachos','🧀',330,35,3,18,7,1.3,150),
  ('Mexicain','Guacamole','🥑',160,8,1,14,2,0.5,60),
  ('Mexicain','Tortilla chips','🌽',500,60,2,25,7,1,40),
  -- ---------------- Libanais / Oriental ----------------
  ('Libanais / Oriental','Houmous','🧆',230,14,0,15,8,1,60),
  ('Libanais / Oriental','Falafel','🧆',330,32,2,18,13,1,50),
  ('Libanais / Oriental','Taboulé','🥗',130,20,2,4,3,0.5,150),
  ('Libanais / Oriental','Fattouche','🥗',90,10,3,4,2,0.5,150),
  ('Libanais / Oriental','Chawarma poulet','🌯',220,12,2,11,18,1.2,250),
  ('Libanais / Oriental','Kefta (brochette)','🍢',250,3,1,18,18,1.2,100),
  ('Libanais / Oriental','Kebbé','🧆',260,20,1,14,12,1,60),
  ('Libanais / Oriental','Baba ganousch','🍆',150,8,3,12,3,0.8,60),
  ('Libanais / Oriental','Feuille de vigne','🍃',180,22,2,8,3,0.9,40),
  ('Libanais / Oriental','Manakish','🫓',300,35,2,14,8,1.2,120),
  ('Libanais / Oriental','Moussaka','🍆',150,9,4,9,7,0.7,300),
  -- ---------------- Desserts ----------------
  ('Desserts','Tiramisu','🍮',280,30,22,15,5,0.2,120),
  ('Desserts','Fondant au chocolat','🍫',380,45,35,20,5,0.3,100),
  ('Desserts','Crème brûlée','🍮',290,25,24,20,4,0.1,120),
  ('Desserts','Panna cotta','🍮',240,22,20,15,4,0.1,120),
  ('Desserts','Île flottante','🥚',130,20,18,4,4,0.1,150),
  ('Desserts','Profiteroles','🍫',300,30,22,18,5,0.2,120),
  ('Desserts','Cheesecake','🍰',320,30,22,20,6,0.4,120),
  ('Desserts','Tarte au citron','🍋',300,40,28,13,4,0.2,120),
  ('Desserts','Tarte Tatin','🍏',250,35,25,11,3,0.2,120),
  ('Desserts','Éclair','🍫',260,30,18,13,5,0.3,90),
  ('Desserts','Millefeuille','🥮',350,40,22,19,5,0.3,100),
  ('Desserts','Paris-Brest','🥮',400,35,20,26,7,0.3,100),
  ('Desserts','Baba au rhum','🍰',290,45,30,9,4,0.2,120),
  ('Desserts','Brownie','🍫',420,50,38,22,5,0.3,80),
  ('Desserts','Salade de fruits','🍓',60,14,12,0.2,0.6,0.01,150),
  ('Desserts','Café gourmand','☕',250,30,22,12,4,0.2,120),
  ('Desserts','Baklava','🍯',430,45,30,25,6,0.2,60),
  ('Desserts','Banana split','🍌',200,26,22,9,3,0.1,200)
) as p(cat, name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- 3) Contrôle : nb de produits par nouvelle catégorie
select c.name as categorie, count(pr.id) as nb_produits
from public.categories c
left join public.products pr on pr.category_id = c.id and pr.user_id is null
where c.name in ('Italien','Burger & Fast-food','Chinois','Thaïlandais','Indien','Mexicain','Libanais / Oriental','Desserts')
group by c.name
order by c.name;
