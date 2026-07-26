-- ============================================================
--  FOOD TRACKER — Enrichissement du catalogue de produits
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Additif et SANS DOUBLON : réexécutable sans risque, et ne
--  touche pas aux produits déjà présents.
-- ============================================================

insert into public.products (category_id, name, emoji)
select c.id, p.name, p.emoji
from (values
  -- ---------------- Féculents ----------------
  ('Féculents','Riz complet','🍚'), ('Féculents','Riz basmati','🍚'),
  ('Féculents','Patate douce','🍠'), ('Féculents','Purée','🥔'),
  ('Féculents','Boulgour','🌾'), ('Féculents','Blé (Ebly)','🌾'),
  ('Féculents','Gnocchi','🥟'), ('Féculents','Polenta','🌽'),
  ('Féculents','Haricots rouges','🫘'), ('Féculents','Haricots blancs','🫘'),
  ('Féculents','Nouilles','🍜'), ('Féculents','Vermicelles','🍝'),

  -- ---------------- Pain & céréales ----------------
  ('Pain & céréales','Pain de mie','🍞'), ('Pain & céréales','Pain de seigle','🥖'),
  ('Pain & céréales','Pain aux céréales','🥖'), ('Pain & céréales','Pain au levain','🍞'),
  ('Pain & céréales','Muesli','🥣'), ('Pain & céréales','Granola','🥣'),
  ('Pain & céréales','Corn flakes','🥣'), ('Pain & céréales','Cracottes','🍘'),
  ('Pain & céréales','Tortilla / Wrap','🫓'), ('Pain & céréales','Pain pita','🫓'),
  ('Pain & céréales','Brioche','🍞'), ('Pain & céréales','Pain grillé','🍞'),

  -- ---------------- Protéines ----------------
  ('Protéines','Dinde','🦃'), ('Protéines','Veau','🥩'),
  ('Protéines','Agneau','🍖'), ('Protéines','Steak haché','🍔'),
  ('Protéines','Saucisse','🌭'), ('Protéines','Merguez','🌭'),
  ('Protéines','Escalope','🍗'), ('Protéines','Cordon bleu','🍗'),
  ('Protéines','Cabillaud','🐟'), ('Protéines','Sardines','🐟'),
  ('Protéines','Maquereau','🐟'), ('Protéines','Moules','🦪'),
  ('Protéines','Lardons','🥓'), ('Protéines','Nuggets','🍗'),
  ('Protéines','Seitan','🌾'), ('Protéines','Tempeh','⬜'),

  -- ---------------- Légumes ----------------
  ('Légumes','Aubergine','🍆'), ('Légumes','Chou-fleur','🥦'),
  ('Légumes','Chou','🥬'), ('Légumes','Choux de Bruxelles','🥬'),
  ('Légumes','Poireau','🥬'), ('Légumes','Betterave','🟣'),
  ('Légumes','Radis','🔴'), ('Légumes','Navet','⚪'),
  ('Légumes','Céleri','🌿'), ('Légumes','Fenouil','🌿'),
  ('Légumes','Endive','🥬'), ('Légumes','Asperge','🌱'),
  ('Légumes','Maïs','🌽'), ('Légumes','Potiron','🎃'),
  ('Légumes','Roquette','🥬'), ('Légumes','Ail','🧄'),

  -- ---------------- Fruits ----------------
  ('Fruits','Mangue','🥭'), ('Fruits','Melon','🍈'),
  ('Fruits','Pastèque','🍉'), ('Fruits','Framboises','🍇'),
  ('Fruits','Cerises','🍒'), ('Fruits','Abricot','🍑'),
  ('Fruits','Prune','🍑'), ('Fruits','Citron','🍋'),
  ('Fruits','Pamplemousse','🍊'), ('Fruits','Figue','🟣'),
  ('Fruits','Grenade','🔴'), ('Fruits','Nectarine','🍑'),
  ('Fruits','Datte','🌴'), ('Fruits','Litchi','🔴'),

  -- ---------------- Produits laitiers ----------------
  ('Produits laitiers','Yaourt grec','🥛'), ('Produits laitiers','Skyr','🥛'),
  ('Produits laitiers','Petit-suisse','🍶'), ('Produits laitiers','Camembert','🧀'),
  ('Produits laitiers','Emmental','🧀'), ('Produits laitiers','Comté','🧀'),
  ('Produits laitiers','Chèvre','🧀'), ('Produits laitiers','Mozzarella','🧀'),
  ('Produits laitiers','Parmesan','🧀'), ('Produits laitiers','Feta','🧀'),
  ('Produits laitiers','Roquefort','🧀'), ('Produits laitiers','Lait végétal','🥥'),
  ('Produits laitiers','Yaourt aux fruits','🍓'), ('Produits laitiers','Ricotta','🥛'),

  -- ---------------- Matières grasses ----------------
  ('Matières grasses','Huile de colza','🫒'), ('Matières grasses','Huile de tournesol','🌻'),
  ('Matières grasses','Noisettes','🌰'), ('Matières grasses','Noix de cajou','🥜'),
  ('Matières grasses','Pistaches','🥜'), ('Matières grasses','Cacahuètes','🥜'),
  ('Matières grasses','Graines de chia','🌱'), ('Matières grasses','Graines de courge','🎃'),
  ('Matières grasses','Graines de tournesol','🌻'), ('Matières grasses','Margarine','🧈'),
  ('Matières grasses','Mayonnaise','🥚'), ('Matières grasses','Olives','🫒'),
  ('Matières grasses','Sésame','⚪'), ('Matières grasses','Noix de pécan','🌰'),

  -- ---------------- Plats préparés ----------------
  ('Plats préparés','Lasagnes','🍝'), ('Plats préparés','Gratin dauphinois','🥔'),
  ('Plats préparés','Hachis parmentier','🥧'), ('Plats préparés','Couscous','🍲'),
  ('Plats préparés','Paella','🥘'), ('Plats préparés','Curry','🍛'),
  ('Plats préparés','Ramen','🍜'), ('Plats préparés','Pad thaï','🍜'),
  ('Plats préparés','Kebab','🥙'), ('Plats préparés','Croque-monsieur','🥪'),
  ('Plats préparés','Salade composée','🥗'), ('Plats préparés','Poke bowl','🍱'),
  ('Plats préparés','Raclette','🧀'), ('Plats préparés','Tartiflette','🥔'),
  ('Plats préparés','Chili con carne','🌶️'), ('Plats préparés','Risotto','🍚'),
  ('Plats préparés','Omelette','🍳'), ('Plats préparés','Nems','🥟'),
  ('Plats préparés','Blanquette','🍲'), ('Plats préparés','Pot-au-feu','🍲'),

  -- ---------------- Encas & sucré ----------------
  ('Encas & sucré','Croissant','🥐'), ('Encas & sucré','Pain au chocolat','🥐'),
  ('Encas & sucré','Cookie','🍪'), ('Encas & sucré','Madeleine','🧁'),
  ('Encas & sucré','Crêpe','🥞'), ('Encas & sucré','Gaufre','🧇'),
  ('Encas & sucré','Muffin','🧁'), ('Encas & sucré','Donut','🍩'),
  ('Encas & sucré','Compote','🍎'), ('Encas & sucré','Barre chocolatée','🍫'),
  ('Encas & sucré','Pop-corn','🍿'), ('Encas & sucré','Crackers','🍘'),
  ('Encas & sucré','Fruits secs','🥜'), ('Encas & sucré','Miel','🍯'),
  ('Encas & sucré','Confiture','🍓'), ('Encas & sucré','Pâte à tartiner','🍫'),
  ('Encas & sucré','Tarte','🥧'), ('Encas & sucré','Flan','🍮'),
  ('Encas & sucré','Riz au lait','🍚'), ('Encas & sucré','Mousse au chocolat','🍫'),
  ('Encas & sucré','Macaron','🍬')
) as p(cat, name, emoji)
join public.categories c on c.name = p.cat
where not exists (
  select 1 from public.products x
  where x.name = p.name and x.category_id = c.id and x.user_id is null
);

-- Combien de produits par catégorie au total ?
select c.name as categorie, count(pr.id) as nb_produits
from public.categories c
left join public.products pr on pr.category_id = c.id and pr.user_id is null
group by c.name
order by c.name;
