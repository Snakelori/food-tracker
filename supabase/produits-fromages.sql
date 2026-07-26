-- ============================================================
--  FOOD TRACKER — Catégorie Fromages (fromages connus)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après nutrition.sql.) Valeurs pour 100 g + portion type (~30 g).
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

-- Nouvelle catégorie « Fromages »
insert into public.categories (name, emoji, sort_order)
select 'Fromages', '🧀', 65
where not exists (select 1 from public.categories c where c.name = 'Fromages');

-- Fromages
insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- ---- Pâtes molles françaises ----
  ('Camembert',        '🧀',300,0.5,0.5,24,20,1.8,30),
  ('Brie',             '🧀',330,0.5,0.5,28,20,1.6,30),
  ('Coulommiers',      '🧀',330,0.5,0.5,28,19,1.6,30),
  ('Reblochon',        '🧀',330,0.5,0.5,27,20,1.5,30),
  ('Munster',          '🧀',340,0.5,0.5,29,19,1.9,30),
  ('Maroilles',        '🧀',350,0.5,0.5,29,21,2.5,30),
  ('Pont-l''Évêque',   '🧀',330,0.5,0.5,27,20,1.9,30),
  ('Époisses',         '🧀',320,1,1,26,18,2,30),
  ('Saint-Nectaire',   '🧀',340,0.5,0.5,28,21,1.6,30),
  ('Saint-Marcellin',  '🧀',320,1,1,27,18,1.5,30),
  -- ---- Pâtes pressées / dures ----
  ('Comté',            '🧀',410,0.5,0.5,34,27,0.9,30),
  ('Beaufort',         '🧀',400,0.5,0.5,33,26,1.2,30),
  ('Emmental',         '🧀',380,0.5,0.5,29,28,0.8,30),
  ('Gruyère',          '🧀',390,0.4,0.4,32,27,1.1,30),
  ('Cantal',           '🧀',370,0.5,0.5,30,24,1.7,30),
  ('Tomme de Savoie',  '🧀',300,0.5,0.5,23,24,1.5,30),
  ('Raclette',         '🧀',360,0.5,0.5,28,23,1.8,30),
  ('Morbier',          '🧀',350,0.5,0.5,29,22,1.6,30),
  ('Ossau-Iraty',      '🧀',400,0.5,0.5,33,25,1.6,30),
  -- ---- Chèvre ----
  ('Chèvre (bûche)',   '🐐',290,1,0.8,22,19,1.4,30),
  ('Crottin de Chavignol','🐐',320,1,1,26,20,1.5,30),
  -- ---- Bleus ----
  ('Roquefort',        '🧀',370,1,0.5,31,21,3.5,30),
  ('Bleu d''Auvergne', '🧀',350,1,0.5,29,20,3,30),
  ('Fourme d''Ambert', '🧀',350,1,0.5,29,20,2.5,30),
  ('Gorgonzola',       '🧀',350,0.5,0.5,30,19,2,30),
  -- ---- Fondus / frais / tartinables ----
  ('Boursin (ail & fines herbes)','🧄',400,2,1,40,7,1.2,25),
  ('Vache qui rit',    '🧀',260,6,6,20,10,2.2,20),
  ('Ricotta',          '🧀',150,3,3,11,9,0.2,50),
  ('Mascarpone',       '🧀',430,4,3,44,5,0.1,30),
  -- ---- Internationaux ----
  ('Mozzarella',       '🧀',250,1,1,18,18,0.7,30),
  ('Burrata',          '🧀',270,2,1,22,13,0.6,50),
  ('Parmesan',         '🧀',400,0.5,0.5,28,36,1.6,15),
  ('Grana Padano',     '🧀',390,0,0,29,33,1.5,15),
  ('Pecorino',         '🧀',390,0,0,29,32,2,15),
  ('Feta',             '🧀',260,1,1,21,14,3,30),
  ('Halloumi',         '🧀',320,2,2,26,20,2.7,30),
  ('Cheddar',          '🧀',400,1.3,0.5,33,25,1.8,30),
  ('Gouda',            '🧀',360,2,2,27,25,2,30),
  ('Edam',             '🧀',330,1.4,1.4,25,25,2,30),
  ('Manchego',         '🧀',390,0.5,0.5,32,25,1.8,30),
  ('Provolone',        '🧀',350,2,1,27,26,1.8,30)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Fromages'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle : nb de fromages chargés
select count(*) as nb_fromages
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Fromages' and pr.user_id is null;
