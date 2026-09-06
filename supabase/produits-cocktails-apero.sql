-- ============================================================
--  FOOD TRACKER — Cocktails & boissons apéro (compléments)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Valeurs pour 100 g/ml + portion (1 verre). Additif et SANS DOUBLON.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Sex on the beach',            '🍹',90,11,10,0,0,0,200),
  ('Tequila sunrise',             '🌅',95,12,11,0,0.2,0,200),
  ('Blue lagoon',                 '💙',90,12,11,0,0,0,200),
  ('Daiquiri',                    '🍹',110,9,8,0,0,0,150),
  ('Mai tai',                     '🍹',140,13,12,0,0,0,200),
  ('Long Island iced tea',        '🍸',160,12,11,0,0,0,220),
  ('Bloody Mary',                 '🍅',45,4,3,0,0.8,0.4,200),
  ('Aperol Spritz',               '🥂',110,12,11,0,0,0,200),
  ('Negroni',                     '🍸',200,6,6,0,0,0,90),
  ('Americano',                   '🍸',100,7,7,0,0,0,120),
  ('Manhattan',                   '🥃',230,4,3,0,0,0,90),
  ('Old Fashioned',               '🥃',210,5,4,0,0,0,90),
  ('White Russian',               '🥛',250,10,9,7,1,0,120),
  ('Pornstar martini',            '🍸',180,16,15,0,0,0,180),
  ('Moscow mule',                 '🍸',100,9,8,0,0,0,200),
  ('Ti-punch',                    '🥃',200,8,7,0,0,0,80),
  ('Planteur',                    '🍹',130,17,16,0,0.2,0,200),
  ('Hugo',                        '🥂',90,9,8,0,0,0,200),
  ('Bellini',                     '🥂',90,9,8,0,0.2,0,150),
  ('Mimosa',                      '🥂',80,7,6,0,0.3,0,150),
  ('Kir royal',                   '🥂',110,8,8,0,0.1,0,120),
  ('Sangria blanche',             '🍷',95,11,10,0,0.2,0,200),
  ('Monaco',                      '🍺',60,13,12,0,0.3,0,250),
  ('Panaché',                     '🍺',30,3,1,0,0.3,0,250),
  ('Cidre',                       '🍏',45,5,4,0,0,0,200),
  ('Pastis (Ricard)',             '🥃',100,0,0,0,0,0,30),
  ('Porto',                       '🍷',160,12,12,0,0.1,0,80),
  ('Martini blanc',               '🍸',145,12,12,0,0,0,80),
  ('Limoncello',                  '🍋',300,30,28,0,0,0,40),
  ('Baileys',                     '🥛',330,25,22,13,3,0.2,50),
  ('Malibu',                      '🥥',250,30,28,0,0,0,40),
  ('Cointreau',                   '🍊',340,30,30,0,0,0,40),
  ('Amaretto',                    '🌰',280,35,33,0,0,0,40),
  ('Get 27 (menthe)',             '🌿',250,30,29,0,0,0,40),
  ('Jägermeister',                '🦌',250,25,24,0,0,0,40)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Cocktails & alcools'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select count(*) as nb_cocktails
from public.products pr join public.categories c on c.id = pr.category_id
where c.name = 'Cocktails & alcools' and pr.user_id is null;
