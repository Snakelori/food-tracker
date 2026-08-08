-- ============================================================
--  FOOD TRACKER — Plus de légumes + catégorie « Plats de légumes »
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après schema.sql + nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- ---------- 1) Enrichir la catégorie « Légumes » (variétés) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Artichaut',            '🌿',47,6,1,0.2,3.3,0.1,120),
  ('Blette (bette)',       '🥬',20,3,1,0.2,1.8,0.2,150),
  ('Chou kale',            '🥬',35,4,1,0.7,3,0.05,80),
  ('Chou-rave',            '🥬',27,4,2,0.1,1.7,0.02,120),
  ('Chou romanesco',       '🥦',25,5,2,0.3,2,0.03,100),
  ('Chou rouge',           '🥬',28,5,3,0.2,1.4,0.03,120),
  ('Chou chinois',         '🥬',16,3,1,0.2,1.2,0.01,120),
  ('Pak choï',             '🥬',13,2,1,0.2,1.5,0.06,120),
  ('Panais',               '🥔',75,13,5,0.3,1.2,0.03,120),
  ('Topinambour',          '🥔',73,12,9,0.1,2,0.01,120),
  ('Rutabaga',             '🥔',38,8,5,0.2,1,0.02,120),
  ('Salsifis',             '🌿',82,15,3,0.2,3,0.02,120),
  ('Radis noir',           '⚫',18,4,2,0.1,1,0.02,100),
  ('Céleri-rave',          '🌰',42,9,2,0.3,1.5,0.1,120),
  ('Céleri branche',       '🌿',16,3,1,0.2,0.7,0.1,100),
  ('Cœur de palmier',      '🌴',28,4,0,0.5,2.5,0.4,80),
  ('Butternut',            '🎃',45,9,2,0.1,1,0.01,150),
  ('Potimarron',           '🎃',45,9,2,0.5,1.5,0.01,150),
  ('Courge spaghetti',     '🎃',31,7,3,0.6,0.6,0.02,150),
  ('Fèves',                '🫘',88,11,2,0.7,8,0.02,100),
  ('Edamame',              '🫛',122,9,2,5,11,0.01,100),
  ('Pois gourmands',       '🫛',42,7,4,0.2,3,0.01,100),
  ('Gombo',                '🌶️',33,7,1,0.2,1.9,0.01,100),
  ('Cresson',              '🌿',20,3,0,0.3,2.6,0.05,60),
  ('Mâche',                '🥬',20,2,1,0.4,2,0.05,60),
  ('Pousses d''épinard',   '🌿',23,2,0,0.4,2.9,0.08,60),
  ('Poivron rouge',        '🫑',31,6,4,0.3,1,0.01,120),
  ('Poivron jaune',        '🫑',27,6,3,0.2,1,0.01,120),
  ('Poivron vert',         '🫑',20,4,2,0.2,0.9,0.01,120),
  ('Piment',               '🌶️',40,9,5,0.4,2,0.01,15)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Légumes'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- 2) Nouvelle catégorie « Plats de légumes » ----------
insert into public.categories (name, emoji, sort_order)
select 'Plats de légumes', '🍆', 42
where not exists (select 1 from public.categories c where c.name = 'Plats de légumes');

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Farcis
  ('Courgette farcie',            '🥒',110,6,3,6,8,0.6,200),
  ('Tomate farcie',               '🍅',120,7,4,7,7,0.6,200),
  ('Poivron farci',               '🫑',115,9,4,6,6,0.6,200),
  ('Aubergine farcie',            '🍆',120,8,4,7,6,0.6,200),
  ('Chou farci',                  '🥬',130,9,3,7,8,0.7,200),
  ('Petits farcis niçois',        '🍅',130,8,4,8,7,0.7,200),
  -- Mijotés / méditerranéens
  ('Ratatouille',                 '🍆',60,6,4,3.5,1.3,0.4,200),
  ('Caponata',                    '🍆',90,9,6,5,1.5,0.5,150),
  ('Tian de légumes',             '🍆',70,7,4,4,1.5,0.4,200),
  ('Curry de légumes',            '🍛',100,11,5,5,3,0.6,250),
  ('Tajine de légumes',           '🍲',85,12,6,3,3,0.5,250),
  -- Gratins & parmigiana
  ('Gratin de courgettes',        '🧀',100,6,3,7,4,0.5,200),
  ('Gratin d''aubergines',        '🧀',110,7,4,8,3.5,0.5,200),
  ('Gratin de chou-fleur',        '🧀',95,6,3,6,5,0.5,200),
  ('Gratin de brocoli',           '🧀',95,6,3,6,5,0.5,200),
  ('Parmigiana d''aubergines',    '🧀',130,8,4,9,5,0.6,200),
  ('Moussaka végétarienne',       '🍆',120,9,4,7,5,0.6,220),
  -- Poêlées / grillés / vapeur
  ('Poêlée de légumes',           '🍳',65,8,4,3,2,0.3,150),
  ('Légumes grillés',             '🔥',80,8,5,4.5,2,0.3,150),
  ('Légumes rôtis au four',       '🔥',90,10,5,5,2,0.3,150),
  ('Wok de légumes',              '🥢',75,9,4,3.5,2.5,0.6,200),
  ('Légumes vapeur',              '♨️',40,6,3,0.4,2,0.02,150),
  ('Courgettes sautées',          '🥒',60,4,3,4,1.5,0.3,150),
  ('Aubergines grillées',         '🍆',70,6,4,4,1.2,0.3,150),
  ('Haricots verts persillade',   '🫛',70,5,2,4,2,0.4,150),
  ('Poêlée de champignons',       '🍄',60,3,1,4,3,0.4,150),
  ('Épinards à la crème',         '🌿',90,4,2,7,3,0.4,150),
  ('Fondue de poireaux',          '🧅',80,6,3,5,2,0.4,150),
  ('Endives au jambon',           '🥬',110,6,3,6,8,0.9,200),
  -- Purées & soupes
  ('Purée de carottes',           '🥕',55,8,5,2,1,0.3,150),
  ('Purée de courgettes',         '🥒',45,4,3,2.5,1.5,0.3,150),
  ('Purée de potiron',            '🎃',50,7,4,2,1,0.3,150),
  ('Purée de brocoli',            '🥦',50,5,2,2.5,3,0.3,150),
  ('Velouté de légumes',          '🥣',50,6,3,2,1.5,0.5,250),
  ('Soupe de légumes',            '🍲',40,6,3,1,1.5,0.5,250),
  -- Beignets / autres
  ('Beignets de légumes (tempura)','🍤',180,18,2,10,4,0.5,100),
  ('Flan de légumes',             '🍮',110,6,3,7,6,0.5,150),
  ('Buddha bowl de légumes',      '🥗',120,15,5,5,4,0.5,300),
  ('Falafels',                    '🧆',330,32,3,18,13,0.6,100)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Plats de légumes'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select 'Légumes' as categorie, count(*) as nb from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Légumes' and pr.user_id is null
union all
select 'Plats de légumes', count(*) from public.products pr
  join public.categories c on c.id = pr.category_id
  where c.name = 'Plats de légumes' and pr.user_id is null;
