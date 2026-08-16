-- ============================================================
--  FOOD TRACKER — Plats français classiques (Plats préparés)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après schema.sql + nutrition.sql.) Valeurs pour 100 g + portion type.
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  -- Mijotés de viande
  ('Cassoulet',                   '🍲',200,14,1,11,12,1,300),
  ('Coq au vin',                  '🍲',150,4,1,8,15,0.9,250),
  ('Bœuf carottes',               '🥕',140,7,4,6,14,0.8,250),
  ('Navarin d''agneau',           '🍲',150,7,3,8,13,0.8,250),
  ('Daube provençale',            '🍲',155,5,2,8,15,0.9,250),
  ('Confit de canard',            '🦆',260,0,0,20,20,1,150),
  ('Choucroute garnie',           '🥬',180,8,3,12,9,1.5,300),
  ('Petit salé aux lentilles',    '🫘',170,14,1,8,12,1.2,300),
  ('Poule au pot',                '🍗',130,5,2,5,15,0.8,300),
  ('Potée auvergnate',            '🍲',130,8,3,7,9,1,300),
  ('Tripes à la mode de Caen',    '🍲',120,3,1,6,13,1,250),
  ('Tête de veau',                '🍽️',180,1,0,13,15,0.9,200),
  ('Garbure',                     '🥣',110,10,3,4,6,0.9,300),
  ('Tournedos Rossini',           '🥩',350,3,1,27,22,1,180),
  -- Œuf / fromage / tartes salées
  ('Quiche lorraine',             '🥧',280,18,2,19,9,1,150),
  ('Croque-monsieur',             '🥪',280,22,3,15,14,1.5,150),
  ('Croque-madame',               '🍳',300,22,3,17,15,1.5,170),
  ('Tarte flambée (flammekueche)','🍕',230,22,3,12,8,1,150),
  ('Soufflé au fromage',          '🧀',230,10,2,16,11,0.9,150),
  ('Gratin de macaronis',         '🧀',160,16,2,8,6,0.7,200),
  -- Fromage fondu (montagne)
  ('Raclette',                    '🧀',350,2,1,28,22,1.5,200),
  ('Fondue savoyarde',            '🧀',300,5,1,20,18,1.2,200),
  -- Poissons / fruits de mer
  ('Bouillabaisse',               '🐟',90,5,1,3,12,1,300),
  ('Moules-frites',               '🦪',170,18,1,7,10,1,300),
  ('Quenelles sauce Nantua',      '🍤',150,14,2,8,6,0.9,200),
  ('Cuisses de grenouille',       '🐸',90,1,0,2,16,0.5,150),
  ('Escargots de Bourgogne',      '🐌',220,2,0,18,12,1.2,80),
  -- Soupes & entrées classiques
  ('Soupe à l''oignon gratinée',  '🧅',90,9,3,4,4,0.8,300),
  ('Vichyssoise',                 '🥣',80,9,3,4,2,0.6,250),
  ('Pâté en croûte',              '🥧',320,22,1,22,10,1.4,120),
  -- Grands classiques bistrot
  ('Steak-frites',                '🍟',220,20,1,10,15,0.5,250),
  ('Andouillette-frites',         '🍟',260,20,1,16,12,1.3,250),
  ('Cuisse de canard confite',    '🦆',270,0,0,21,20,1,150)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Plats préparés'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_plats_prepares
from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Plats préparés' and pr.user_id is null;
