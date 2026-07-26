-- ============================================================
--  FOOD TRACKER — Types de flan (catégorie Desserts)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Garantir la catégorie Desserts (si pas déjà créée)
insert into public.categories (name, emoji, sort_order)
select 'Desserts', '🍰', 95
where not exists (select 1 from public.categories c where c.name = 'Desserts');

-- Types de flan
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Flan pâtissier',        '🍮',150,24,18,4,4,0.15,120),
  ('Flan parisien',         '🍮',200,28,18,8,4,0.20,120),
  ('Flan nature',           '🍮',130,20,17,3,4,0.10,120),
  ('Flan aux œufs',         '🥚',130,20,17,3,4,0.10,120),
  ('Flan au caramel',       '🍮',140,22,20,4,3.5,0.10,120),
  ('Flan vanille',          '🍮',130,20,17,3,4,0.10,120),
  ('Flan chocolat',         '🍫',160,23,19,5,4,0.10,120),
  ('Flan coco',             '🥥',200,26,22,9,3.5,0.10,120),
  ('Flan café',             '☕',135,20,17,4,4,0.10,120),
  ('Flan antillais',        '🌴',210,28,24,9,4,0.10,120),
  ('Flan espagnol',         '🍮',145,23,21,4,4,0.10,120),
  ('Flan pâtissier sans pâte','🍮',140,22,18,4,4,0.10,120)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Desserts'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle : les flans de la catégorie Desserts
select pr.name, pr.energy_kcal, pr.sugar_g, pr.portion_g
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Desserts' and pr.name ilike 'flan%'
order by pr.name;
