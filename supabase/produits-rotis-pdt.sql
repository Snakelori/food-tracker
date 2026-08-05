-- ============================================================
--  FOOD TRACKER — Rôtis (Protéines) & plats à base de pomme de terre (Féculents)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après schema.sql + nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- ---------- Rôtis (catégorie Protéines) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Rôti de porc',              '🍖',250,0,0,18,22,0.9,120),
  ('Rôti de porc Orloff',       '🍖',270,1,1,20,20,1.4,130),
  ('Rôti de bœuf',              '🥩',180,0,0,8,27,0.8,120),
  ('Rosbif',                    '🥩',175,0,0,7,27,0.8,120),
  ('Rôti de veau',              '🥩',160,0,0,6,27,0.8,120),
  ('Rôti de dinde',             '🦃',150,0,0,4,28,0.8,120),
  ('Rôti de poulet',            '🍗',200,0,0,11,25,0.9,120),
  ('Rôti d''agneau (gigot)',    '🐑',230,0,0,15,24,0.9,120),
  ('Rôti de canard',            '🦆',220,0,0,14,23,0.9,120),
  ('Filet mignon rôti',         '🍖',160,0,0,6,26,0.8,120),
  ('Rôti de porc au four',      '🍖',245,0,0,17,22,1,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Protéines'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- ---------- Pommes de terre (catégorie Féculents) ----------
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Pommes dauphine',           '🥔',280,30,1,15,4,0.8,100),
  ('Pommes noisettes',          '🥔',250,28,1,13,3,0.7,100),
  ('Pommes duchesse',           '🥔',200,25,1,9,4,0.7,100),
  ('Pommes de terre sautées',   '🥔',180,24,1,8,3,0.5,150),
  ('Pommes de terre rissolées', '🥔',170,24,1,7,3,0.5,150),
  ('Pommes de terre vapeur',    '🥔',85,19,1,0.1,2,0.02,150),
  ('Pommes de terre au four',   '🥔',95,20,1,0.2,2.5,0.02,180),
  ('Pommes de terre grenaille', '🥔',100,21,1,1,2.5,0.3,150),
  ('Pommes allumettes',         '🍟',320,40,1,16,4,0.6,100),
  ('Potatoes / wedges',         '🥔',190,25,1,9,3,0.7,130),
  ('Croquettes de pomme de terre','🥔',230,27,1,12,3,0.8,100),
  ('Rösti',                     '🥔',180,22,1,9,3,0.6,120),
  ('Galette de pomme de terre', '🥔',190,22,1,10,3,0.6,100),
  ('Gratin dauphinois',         '🥔',160,14,2,10,4,0.6,150),
  ('Pommes boulangère',         '🥔',110,18,1,3,2.5,0.5,150),
  ('Aligot',                    '🥔',200,18,2,12,6,0.8,150),
  ('Tartiflette',               '🧀',180,12,2,12,6,0.8,200),
  ('Hachis parmentier',         '🥧',130,12,2,6,7,0.7,200),
  ('Purée de pommes de terre',  '🥔',90,14,1,3,2,0.4,150),
  ('Frites au four',            '🍟',180,28,1,6,3,0.5,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Féculents'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select 'Protéines (rôtis ajoutés)' as info, count(*) as nb
from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Protéines' and pr.user_id is null
union all
select 'Féculents (pdt ajoutées)', count(*)
from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Féculents' and pr.user_id is null;
