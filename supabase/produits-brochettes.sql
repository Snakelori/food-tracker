-- ============================================================
--  FOOD TRACKER — Catégorie Brochettes & grillades
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type (~1 brochette).
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie
insert into public.categories (name, emoji, sort_order)
select 'Brochettes & grillades', '🍢', 35
where not exists (select 1 from public.categories c where c.name = 'Brochettes & grillades');

-- Produits
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Volailles
  ('Brochette de poulet',         '🍗',170,2,1,7,25,0.8,100),
  ('Brochette de poulet mariné',  '🍗',180,4,3,7,24,1,100),
  ('Brochette de dinde',          '🦃',150,2,1,4,27,0.8,100),
  ('Brochette de canard',         '🦆',230,2,1,15,22,0.9,100),
  ('Brochette de magret de canard','🦆',250,2,1,17,22,0.9,100),
  -- Viandes rouges
  ('Brochette de bœuf',           '🥩',210,2,1,12,24,0.8,100),
  ('Brochette de bœuf-fromage',   '🧀',250,5,3,16,18,1.2,100),
  ('Brochette d''agneau',         '🐑',240,2,1,16,23,0.9,100),
  ('Brochette de veau',           '🥩',180,2,1,9,24,0.8,100),
  ('Brochette de porc',           '🥓',220,2,1,14,22,0.9,100),
  ('Brochette de porc mariné',    '🥓',210,4,3,12,22,1,100),
  ('Brochette de merguez',        '🌭',280,2,1,23,16,1.8,90),
  ('Brochette mixte',             '🍢',210,3,2,13,21,1,120),
  -- Poissons & fruits de mer
  ('Brochette de saumon',         '🐟',200,1,0,12,22,0.6,100),
  ('Brochette de thon',           '🐟',150,1,0,4,27,0.6,100),
  ('Brochette de lotte',          '🐟',100,1,0,2,20,0.5,100),
  ('Brochette de crevettes',      '🦐',110,2,1,2,21,1,100),
  ('Brochette de gambas',         '🦐',110,2,1,2,21,1,100),
  ('Brochette de Saint-Jacques',  '🐚',110,4,1,2,18,0.8,90),
  -- Végé & fromage
  ('Brochette de légumes',        '🫑',70,8,5,3,2,0.4,120),
  ('Brochette de halloumi',       '🧀',300,3,2,24,19,2,90),
  ('Brochette de tofu',           '⬜',130,4,2,8,12,0.5,100),
  ('Brochette de champignons',    '🍄',60,5,2,3,3,0.4,100),
  -- Spécialités
  ('Chich taouk (poulet)',        '🍢',175,3,2,7,25,1,100),
  ('Souvlaki (porc grec)',        '🍢',200,3,1,11,22,1,100),
  ('Yakitori (poulet japonais)',  '🍢',200,6,4,9,22,1.2,40)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Brochettes & grillades'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_brochettes
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Brochettes & grillades' and pr.user_id is null;
