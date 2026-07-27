-- ============================================================
--  FOOD TRACKER — Salades (complément)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après produits-salades.sql.) Additif et SANS DOUBLON.
-- ============================================================

-- Garantir la catégorie Salades
insert into public.categories (name, emoji, sort_order)
select 'Salades', '🥗', 45
where not exists (select 1 from public.categories c where c.name = 'Salades');

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Salade d''endives',            '🥬',80,4,1.5,6,1.5,0.4,120),
  ('Salade de haricots verts',     '🫛',60,5,1.5,4,1.8,0.4,150),
  ('Salade de pois chiches',       '🫘',160,20,2,6,7,0.6,200),
  ('Salade de crudités',           '🥕',60,6,3,3,1.5,0.4,150),
  ('Salade tomates-mozzarella',    '🍅',150,4,3,11,8,0.6,200),
  ('Salade tomates-feta',          '🧀',130,5,3,9,5,0.8,200),
  ('Salade de maïs',               '🌽',110,18,4,3,3,0.5,120),
  ('Salade de chou rouge',         '🥬',120,8,6,9,1.5,0.4,120),
  ('Salade de surimi',             '🦀',130,8,3,7,8,1,200),
  ('Salade de fruits de mer',      '🦐',120,4,2,6,12,0.9,200),
  ('Salade de courgettes',         '🥒',60,5,3,4,1.5,0.4,150),
  ('Salade de champignons',        '🍄',70,4,2,5,2.5,0.4,120),
  ('Salade betterave-chèvre',      '🧀',140,9,7,9,5,0.6,150),
  ('Salade de roquette',           '🌱',40,3,1.5,3,1.5,0.3,60),
  ('Salade de chou-fleur',         '🥦',70,6,2,4,2.5,0.4,120),
  ('Salade de riz au thon',        '🐟',180,22,2,7,8,0.8,250)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Salades'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

select count(*) as nb_salades
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Salades' and pr.user_id is null;
