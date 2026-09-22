-- ============================================================
--  FOOD TRACKER — Œufs & préparations (Protéines)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g + portion type. Additif et SANS DOUBLON.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Œuf au plat',              '🍳',195,1,1,15,13,0.4,60),
  ('Œufs brouillés',           '🍳',165,1,1,12,11,0.6,120),
  ('Œuf dur',                  '🥚',155,1,1,11,13,0.3,50),
  ('Œuf poché',                '🥚',145,0.7,0.4,10,13,0.3,50),
  ('Œuf à la coque',           '🥚',145,0.7,0.4,10,13,0.3,50),
  ('Œuf mollet',               '🥚',145,0.7,0.4,10,13,0.3,50),
  ('Œuf cocotte',              '🥚',180,2,1,14,10,0.5,100),
  ('Œuf mayonnaise',           '🥚',250,1,1,23,8,0.6,100),
  ('Œuf poêlé',                '🍳',190,1,1,15,13,0.4,60),
  ('Omelette au fromage',      '🧀',200,1,1,16,13,0.8,130),
  ('Omelette aux champignons', '🍄',150,2,1,11,11,0.6,150),
  ('Omelette au jambon',       '🍖',170,1,1,12,14,1,140),
  ('Omelette aux fines herbes','🌿',155,1,1,12,11,0.6,120),
  ('Œufs bénédicte',           '🍳',220,10,2,16,10,1,150),
  ('Frittata',                 '🍳',160,3,1,11,11,0.6,150),
  ('Tortilla (omelette pdt)',  '🥔',170,12,1,10,7,0.6,150),
  ('Œufs à la florentine',     '🌿',160,3,2,11,10,0.6,150),
  ('Œuf de caille',            '🥚',158,0.4,0.4,11,13,0.5,10)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Protéines'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_oeufs
from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Protéines' and pr.user_id is null and pr.name ilike '%œuf%';
