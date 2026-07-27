-- ============================================================
--  FOOD TRACKER — Apéritif, Viennoiseries, Boissons chaudes,
--  Confiserie & chocolats, Cocktails & alcools
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g (ou 100 ml pour les
--  boissons) + portion type. Additif et SANS DOUBLON.
-- ============================================================

-- 1) Nouvelles catégories
insert into public.categories (name, emoji, sort_order)
select v.name, v.emoji, v.sort_order
from (values
  ('Viennoiseries',            '🥐', 21),
  ('Boissons chaudes',        '☕', 62),
  ('Apéritif',                '🥨', 93),
  ('Confiserie & chocolats',  '🍫', 94),
  ('Cocktails & alcools',     '🍹', 97)
) as v(name, emoji, sort_order)
where not exists (select 1 from public.categories c where c.name = v.name);

-- 2) Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- ---------------- Apéritif ----------------
  ('Apéritif','Cacahuètes','🥜',600,15,4,50,25,1,25),
  ('Apéritif','Cacahuètes enrobées','🥜',500,45,30,30,12,0.6,25),
  ('Apéritif','Pistaches','🥜',560,28,8,45,20,0.5,25),
  ('Apéritif','Noix de cajou','🥜',550,30,6,44,18,0.5,25),
  ('Apéritif','Chips','🥔',540,50,1,34,6,1.2,30),
  ('Apéritif','Biscuits apéritif','🥨',490,60,3,22,9,2,25),
  ('Apéritif','Crackers salés','🍘',480,62,4,20,9,2.2,20),
  ('Apéritif','Bretzels','🥨',380,80,2,3,10,2.5,30),
  ('Apéritif','Gressins','🥖',400,72,3,8,12,2,15),
  ('Apéritif','Pop-corn','🍿',480,60,1,22,9,1.5,30),
  ('Apéritif','Olives','🫒',145,4,0,15,1,3.3,20),
  ('Apéritif','Saucisson','🌭',450,1,0.5,40,24,3.5,30),
  ('Apéritif','Chorizo','🌶️',450,2,1,38,24,3,30),
  ('Apéritif','Cubes de fromage','🧀',350,1,0.5,28,25,1.6,30),
  ('Apéritif','Tapenade','🫒',250,5,1,24,3,3,20),
  ('Apéritif','Rillettes','🥫',400,0,0,38,15,1.8,30),
  ('Apéritif','Feuilletés apéritif','🥐',400,35,2,25,8,1.2,20),
  ('Apéritif','Mini-quiches','🥧',300,22,2,19,9,1,30),
  -- ---------------- Viennoiseries ----------------
  ('Viennoiseries','Croissant','🥐',406,42,8,23,8,0.9,60),
  ('Viennoiseries','Croissant aux amandes','🥐',450,40,18,28,9,0.7,80),
  ('Viennoiseries','Pain au chocolat','🥐',430,45,14,24,8,0.7,70),
  ('Viennoiseries','Pain aux raisins','🍥',380,50,20,16,7,0.6,80),
  ('Viennoiseries','Chausson aux pommes','🍏',320,40,15,16,4,0.5,90),
  ('Viennoiseries','Brioche','🍞',380,50,12,16,8,0.8,40),
  ('Viennoiseries','Chouquette','⚪',380,45,20,18,8,0.5,15),
  ('Viennoiseries','Beignet','🍩',400,45,15,20,6,0.5,70),
  ('Viennoiseries','Beignet à la confiture','🍩',350,45,18,15,6,0.5,80),
  ('Viennoiseries','Pain suisse','🍞',400,45,18,20,8,0.6,90),
  ('Viennoiseries','Kouglof','🍰',380,48,20,17,8,0.5,60),
  ('Viennoiseries','Pain viennois','🥖',300,52,8,6,9,1,50),
  -- ---------------- Boissons chaudes (pour 100 ml) ----------------
  ('Boissons chaudes','Expresso','☕',2,0,0,0,0.1,0,40),
  ('Boissons chaudes','Café noir','☕',2,0,0,0,0.1,0,100),
  ('Boissons chaudes','Café au lait','☕',40,4,4,1.5,2,0.05,150),
  ('Boissons chaudes','Café crème','☕',50,3,3,3,2,0.05,150),
  ('Boissons chaudes','Cappuccino','☕',40,4,4,2,2.5,0.05,150),
  ('Boissons chaudes','Latte','☕',55,5,5,2.5,3,0.05,250),
  ('Boissons chaudes','Café viennois','☕',120,8,7,9,2,0.05,150),
  ('Boissons chaudes','Thé nature','🍵',1,0,0,0,0,0,200),
  ('Boissons chaudes','Thé au lait','🍵',30,3,3,1,1.5,0.03,200),
  ('Boissons chaudes','Tisane / infusion','🍵',1,0,0,0,0,0,200),
  ('Boissons chaudes','Chocolat chaud','🍫',90,12,11,3,3,0.1,200),
  ('Boissons chaudes','Chocolat chaud viennois','🍫',150,15,13,8,3,0.1,200),
  ('Boissons chaudes','Chai latte','🍵',90,13,12,3,2.5,0.1,250),
  ('Boissons chaudes','Matcha latte','🍵',70,8,6,3,2.5,0.05,250),
  ('Boissons chaudes','Lait chaud','🥛',60,5,5,3,3,0.1,200),
  -- ---------------- Confiserie & chocolats ----------------
  ('Confiserie & chocolats','Chocolat noir','🍫',550,45,30,40,8,0.02,25),
  ('Confiserie & chocolats','Chocolat au lait','🍫',545,50,48,33,6,0.05,25),
  ('Confiserie & chocolats','Chocolat blanc','🍫',560,58,55,33,6,0.15,25),
  ('Confiserie & chocolats','Chocolat praliné','🍫',560,52,48,36,7,0.1,25),
  ('Confiserie & chocolats','Truffes au chocolat','🍫',550,45,40,38,5,0.1,15),
  ('Confiserie & chocolats','Rocher chocolat','🍫',560,48,42,38,8,0.1,20),
  ('Confiserie & chocolats','Bouchée chocolat','🍫',500,55,48,28,6,0.1,15),
  ('Confiserie & chocolats','Bonbons','🍬',350,85,60,0,1,0.05,30),
  ('Confiserie & chocolats','Bonbons gélifiés','🐻',340,80,55,0,5,0.1,30),
  ('Confiserie & chocolats','Réglisse','⚫',350,80,55,2,3,0.5,20),
  ('Confiserie & chocolats','Sucette','🍭',380,95,70,0,0,0.05,15),
  ('Confiserie & chocolats','Caramel','🍬',400,80,60,10,2,0.3,20),
  ('Confiserie & chocolats','Nougat','🍬',400,70,55,12,6,0.1,25),
  ('Confiserie & chocolats','Guimauve','🍬',330,80,58,0,2,0.1,20),
  ('Confiserie & chocolats','Chewing-gum','🍬',250,65,60,0,0,0,3),
  ('Confiserie & chocolats','Pâte de fruits','🍬',340,85,75,0,0.3,0.02,20),
  ('Confiserie & chocolats','Dragées','🥚',450,70,60,18,6,0.05,20),
  ('Confiserie & chocolats','Pâte d''amande','🌰',460,55,50,24,9,0.02,20),
  ('Confiserie & chocolats','Calisson','🍬',430,75,65,12,6,0.02,15),
  ('Confiserie & chocolats','Loukoum','🍬',360,85,70,2,1,0.05,20),
  -- ---------------- Cocktails & alcools (pour 100 ml) ----------------
  ('Cocktails & alcools','Mojito','🍹',80,10,9,0,0,0,250),
  ('Cocktails & alcools','Virgin mojito','🍹',60,14,13,0,0,0,250),
  ('Cocktails & alcools','Piña colada','🍹',180,22,20,5,1,0,250),
  ('Cocktails & alcools','Margarita','🍸',150,12,11,0,0,0,200),
  ('Cocktails & alcools','Cosmopolitan','🍸',160,12,11,0,0,0,150),
  ('Cocktails & alcools','Spritz','🥂',110,12,11,0,0,0,200),
  ('Cocktails & alcools','Gin tonic','🍸',90,8,8,0,0,0,250),
  ('Cocktails & alcools','Cuba libre','🥤',100,11,10,0,0,0,250),
  ('Cocktails & alcools','Caïpirinha','🍹',160,14,12,0,0,0,200),
  ('Cocktails & alcools','Sangria','🍷',100,12,11,0,0.2,0,200),
  ('Cocktails & alcools','Punch','🍹',130,16,15,0,0.2,0,200),
  ('Cocktails & alcools','Kir','🍷',120,9,9,0,0.1,0,120),
  ('Cocktails & alcools','Bière','🍺',45,3.6,0,0,0.5,0,250),
  ('Cocktails & alcools','Vin rouge','🍷',85,2.6,0.6,0,0.1,0,120),
  ('Cocktails & alcools','Vin blanc','🍷',82,2.6,1,0,0.1,0,120),
  ('Cocktails & alcools','Rosé','🍷',80,2.5,1,0,0.1,0,120),
  ('Cocktails & alcools','Champagne','🥂',80,1.4,1.2,0,0.2,0,120),
  ('Cocktails & alcools','Whisky','🥃',250,0,0,0,0,0,40),
  ('Cocktails & alcools','Vodka','🍸',230,0,0,0,0,0,40),
  ('Cocktails & alcools','Rhum','🥃',230,0,0,0,0,0,40),
  ('Cocktails & alcools','Apéritif (Martini, Porto)','🍸',150,12,12,0,0,0,80)
) as p(cat, name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- 3) Contrôle : nb de produits par nouvelle catégorie
select c.name as categorie, count(pr.id) as nb
from public.categories c
left join public.products pr on pr.category_id = c.id and pr.user_id is null
where c.name in ('Viennoiseries','Boissons chaudes','Apéritif','Confiserie & chocolats','Cocktails & alcools')
group by c.name order by c.name;
