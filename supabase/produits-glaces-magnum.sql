-- ============================================================
--  FOOD TRACKER — Magnum (bâtonnets glacés enrobés)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  (Après produits-glaces.sql.) Valeurs pour 100 g + portion (1 bâtonnet).
--  Additif et SANS DOUBLON : réexécutable sans risque.
-- ============================================================

insert into public.products (category_id, name, emoji, energy_kcal, carb_g, sugar_g, fat_g, protein_g, salt_g, portion_g)
select c.id, p.name, p.emoji, p.kcal, p.carb, p.sugar, p.fat, p.prot, p.salt, p.portion
from (values
  ('Magnum classique',          '🍫',316,30,27,20,4,0.15,79),
  ('Magnum amande',             '🌰',329,28,26,22,4.5,0.15,79),
  ('Magnum chocolat blanc',     '🤍',316,30,28,20,3.8,0.15,79),
  ('Magnum double caramel',     '🍮',360,37,31,22,3.5,0.25,100),
  ('Magnum double chocolat',    '🍫',350,35,29,22,4,0.2,100),
  ('Magnum praliné',            '🌰',330,29,26,22,4,0.15,79),
  ('Magnum fruits rouges',      '🍓',300,32,29,17,3.5,0.12,79),
  ('Magnum mini (1 bâtonnet)',  '🍫',350,30,27,24,4,0.15,44)
) as p(name, emoji, kcal, carb, sugar, fat, prot, salt, portion)
join public.categories c on c.name = 'Glaces & desserts glacés'
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Contrôle
select name from public.products pr
join public.categories c on c.id = pr.category_id
where c.name = 'Glaces & desserts glacés' and pr.user_id is null and pr.name ilike 'magnum%'
order by name;
