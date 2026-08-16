# Journal des versions

Toutes les évolutions notables de l'application sont consignées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/).

## [2.8.1] — 2026-08-08
### Ajouté — Bilan énergétique & objectifs de macros
- **⚖️ Bilan du jour** dans la Journée : kcal **ingérées − dépensées = solde net**,
  jauge de progression vs objectif calorique.
- **Objectifs de macros** (protéines / glucides / lipides) dans 🎯 Objectif, avec barres
  de progression du jour. À activer via `supabase/macros.sql` (repli automatique sinon).

## [2.8.0] — 2026-08-08
### Ajouté — Saisie plus rapide
- **⭐ Fréquents** : le sélecteur d'aliment ouvre sur vos produits les plus utilisés
  (60 derniers jours) pour un ajout en un tap.
- **📋 « Comme la dernière fois »** : sur un repas vide, un bouton recopie le dernier repas
  du même type (aliments + boissons) en un clic.

## [2.7.8] — 2026-08-08
### Enrichi
- **Glaces** : ajout des **Magnum** nommés (classique, amande, chocolat blanc, double
  caramel, double chocolat, praliné, fruits rouges, mini). À charger via
  `supabase/produits-glaces-magnum.sql`.

## [2.7.7] — 2026-08-08
### Enrichi
- Nouvelle catégorie **🍦 Glaces & desserts glacés** : ~43 produits — parfums (vanille,
  chocolat, pistache, café, caramel beurre salé, stracciatella, cookies, menthe-choco…),
  **sorbets** (citron, fraise, mangue, framboise, cassis, coco…), et **desserts glacés**
  (cornet, bâtonnet enrobé, esquimau, coupe, banana split, liégeois, dame blanche,
  vacherin, frozen yogurt, granité…). À charger via `supabase/produits-glaces.sql`.

## [2.7.6] — 2026-08-08
### Enrichi — Fast-food & kebabs
- **Burger & Fast-food** : Big Mac, Whopper, Royal Cheese, double/triple cheeseburger,
  Filet-O-Fish, McChicken, Zinger, nuggets (x6/x9), wings, poulet frit, tacos français,
  frites moyenne/grande, potatoes, McFlurry, sundae, donut, muffin, cookie, chausson…
- **Libanais / Oriental** : kebab (sandwich, galette/dürüm, poulet), assiette kebab,
  kebab-frites, Adana, İskender.
- À charger via `supabase/produits-fastfood-kebab.sql`.

## [2.7.5] — 2026-08-08
### Enrichi
- **Macédoine** : macédoine de légumes (nature et mayonnaise) dans Légumes, et macédoine
  de fruits dans Fruits. À charger via `supabase/produits-macedoine.sql`.

## [2.7.4] — 2026-08-08
### Enrichi — Plats français classiques
- **Plats préparés** : +33 classiques — cassoulet, coq au vin, bœuf carottes, navarin
  d'agneau, daube, confit de canard, choucroute garnie, petit salé aux lentilles, poule
  au pot, potée, tête de veau, tournedos Rossini, quiche lorraine, croque-monsieur/madame,
  tarte flambée, raclette, fondue savoyarde, bouillabaisse, moules-frites, quenelles,
  cuisses de grenouille, escargots, soupe à l'oignon, pâté en croûte, steak-frites…
  À charger via `supabase/produits-plats-francais.sql`.

## [2.7.3] — 2026-08-08
### Enrichi — Viandes
- **Protéines** : +45 produits — boulettes de viande (bœuf, veau, agneau/kefta, porc,
  volaille, poisson, suédoises), steak haché (5/15 % + végétal), panés (cordon bleu,
  escalope milanaise, nuggets, tenders), morceaux (blanc/cuisse/aile de poulet, entrecôte,
  côtes de porc/agneau, magret, travers…), saucisses (chipolata, Toulouse, knacki, merguez,
  boudin noir/blanc, andouillette…) et charcuterie (jambon cru, bacon, lardons, chorizo,
  salami, mortadelle, pâté, rillettes).
- **Plats préparés** : bœuf bourguignon, blanquette, pot-au-feu, chili con carne, lasagnes,
  boulettes sauce tomate, curry de bœuf, poulet basquaise.
- À charger via `supabase/produits-viandes.sql`.

## [2.7.2] — 2026-08-08
### Ajouté — Estimation des calories d'activité
- Les **calories dépensées se calculent automatiquement** d'après l'activité choisie,
  la durée, l'intensité et votre **dernier poids** (formule MET × poids × durée).
  Le champ reste modifiable ; une note indique l'estimation et le poids utilisé.

## [2.7.1] — 2026-08-08
### Amélioré — Activités
- **Sélecteur d'activités** (vélo, natation, course à pied, musculation, yoga, sports…) :
  un clic remplit le nom, tout en gardant la saisie libre possible.
- **Durée en heures / minutes** (au lieu des seules minutes).

## [2.7.0] — 2026-08-08
### Ajouté — Courbes de tendance (Analyses)
- Nouvelle carte **📈 Tendances quotidiennes** : courbes d'évolution sur les 30 derniers
  jours avec repas —
  **🔥 calories ingérées / jour** (avec ligne d'objectif si défini),
  **🍎 encas / jour**, et **🍬 sucres / jour**.
- Chaque courbe affiche la **moyenne** et la **dernière valeur**, avec aire dégradée.

## [2.6.1] — 2026-08-08
### Enrichi
- **Légumes** : +30 variétés (artichaut, blette, chou kale/rouge/romanesco, panais,
  topinambour, butternut, potimarron, courge spaghetti, céleri-rave, fèves, edamame,
  pois gourmands, poivrons rouge/jaune/vert…).
- Nouvelle catégorie **🍆 Plats de légumes** : ratatouille, farcis (courgette, tomate,
  poivron, aubergine, chou), gratins, parmigiana, moussaka végé, poêlées, légumes grillés/
  rôtis/vapeur, wok, curry & tajine de légumes, purées, veloutés, tempura, falafels…
  avec valeurs nutritionnelles. À charger via `supabase/produits-legumes.sql`.

## [2.6.0] — 2026-08-06
### Ajouté — Rappels configurables depuis l'app
- **Réglages → 🔔 Rappels de saisie → Gérer** : modifier l'**heure** de chaque rappel,
  **activer/désactiver**, choisir le mode **🧠 Intelligent**, et **ajouter** des rappels.
- Rappels **encas** et **pesée hebdomadaire** (jour + heure au choix) fournis par défaut
  (à activer), + rappels **personnalisés**.
- Le workflow Telegram devient **dynamique** : il lit la table `reminders` toutes les 15 min
  et envoie les rappels dus (garde anti-doublon : un envoi max par jour et par rappel).
- À activer via `supabase/rappels.sql` (les rappels par défaut se créent à la 1re ouverture).

## [2.5.0] — 2026-08-06
### Ajouté — Rappels de saisie par Telegram
- **Rappels intelligents** : un message Telegram est envoyé **seulement si** le repas
  n'a pas encore été saisi (petit-déj 09h30, déjeuner 13h45, dîner 20h45, heure de Paris).
- Automatisé via GitHub Actions (`.github/workflows/rappels-telegram.yml`), en réutilisant
  le secret `SUPABASE_DB_URL` déjà en place. DST-safe (été/hiver).
- Bouton **« Run workflow » (test)** pour vérifier l'envoi immédiatement.
- Guide d'installation : `docs/RAPPELS-TELEGRAM.md` (créer le bot, récupérer le chat_id,
  ajouter les secrets `TELEGRAM_BOT_TOKEN` et `TELEGRAM_CHAT_ID`).

## [2.4.4] — 2026-08-06
### Enrichi
- Nouvelle catégorie **🐟 Poissons & fruits de mer** : ~60 produits **panés et non panés**
  (saumon, cabillaud, thon, sardine, sole, dorade, bar, saumon fumé, poisson pané, bâtonnets,
  nuggets, fish & chips, calamars/crevettes panés…) + fruits de mer (moules, huîtres,
  Saint-Jacques, crevettes, calamars, crabe, homard, surimi…). À charger via
  `supabase/produits-poissons.sql`.

## [2.4.3] — 2026-08-06
### Corrigé
- **Recherche d'aliments insensible aux accents** : taper « roti », « puree » ou « rosti »
  trouve désormais « Rôti », « Purée », « Rösti »… (dans le sélecteur d'aliment et le
  gestionnaire de produits).

## [2.4.2] — 2026-08-06
### Enrichi
- **Rôtis** (catégorie Protéines) : rôti de porc, porc Orloff, bœuf, rosbif, veau, dinde,
  poulet, agneau (gigot), canard, filet mignon rôti… avec valeurs nutritionnelles.
- **Plats à base de pomme de terre** (catégorie Féculents) : pommes dauphine, noisettes,
  duchesse, sautées, rissolées, vapeur, au four, grenaille, allumettes, potatoes/wedges,
  croquettes, rösti, galette, gratin dauphinois, boulangère, aligot, tartiflette, hachis
  parmentier, purée, frites au four. À charger via `supabase/produits-rotis-pdt.sql`.

## [2.4.1] — 2026-07-28
### Ajouté
- **Plusieurs encas par jour**, chacun avec **sa propre heure** de prise : bouton
  « + Ajouter un encas » ; chaque encas a sa carte (aliments, boisson, totaux nutritionnels).

## [2.4.0] — 2026-07-28
### Ajouté — Suivi du poids & objectifs
- Carte **⚖️ Poids & objectif** en tête de l'onglet Analyses : poids actuel, **objectif**,
  barre de progression, kg à perdre, variation depuis le début, **IMC**, et **courbe d'évolution**.
- Bouton **+ Peser** (une pesée par jour) et **🎯 Objectif** (poids cible, poids de départ,
  taille, objectif calories/jour).
- L'objectif calorique s'affiche dans la carte Nutrition (moyenne vs objectif).
- À activer via `supabase/poids.sql`.

## [2.3.7] — 2026-07-28
### Enrichi
- 5 nouvelles catégories : **🥨 Apéritif** (cacahuètes, biscuits apéro, saucisson…),
  **🥐 Viennoiseries**, **☕ Boissons chaudes** (cafés, thés, chocolat chaud…),
  **🍫 Confiserie & chocolats** et **🍹 Cocktails & alcools** — ~86 produits avec valeurs
  nutritionnelles. À charger via `supabase/produits-apero-boissons-confiserie.sql`.

## [2.3.6] — 2026-07-28
### Ajouté
- **Modifier un aliment déjà saisi** dans un repas : bouton ✏️ sur chaque aliment pour
  changer sa **quantité** (avec aperçu nutritionnel en direct) ou le retirer.

## [2.3.5] — 2026-07-28
### Enrichi
- Nouvelle catégorie **🍢 Brochettes & grillades** : 26 brochettes (poulet, bœuf, canard,
  magret, agneau, porc, merguez, saumon, crevettes, halloumi, légumes, chich taouk,
  souvlaki…) avec valeurs nutritionnelles. À charger via `supabase/produits-brochettes.sql`.

## [2.3.4] — 2026-07-27
### Ajouté
- **Recherche d'aliments** dans le sélecteur : tapez un nom pour trouver un produit dans
  **toutes les catégories** (avec son libellé de catégorie), en plus de la navigation par onglets.
### Enrichi
- Catégorie **Salades** : +16 types (salade d'endives, tomates-mozzarella, pois chiches,
  crudités, chou rouge, surimi, fruits de mer…). À charger via `supabase/produits-salades-2.sql`.

## [2.3.3] — 2026-07-27
### Enrichi
- Nouvelle catégorie **🧁 Gâteaux & goûter** : 32 classiques (madeleines nature/chocolat/citron/miel,
  quatre-quarts, financiers, marbré, cakes, kouign-amann, cannelé, far breton, pain d'épices…)
  avec valeurs nutritionnelles. À charger via `supabase/produits-gateaux.sql`.

## [2.3.2] — 2026-07-27
### Corrigé
- **Bug de date** : la nuit (après minuit), l'application affichait la veille comme
  « aujourd'hui » et les flèches étaient décalées d'un jour — la date était calculée en
  UTC. Elle utilise désormais l'**heure locale** partout.

## [2.3.1] — 2026-07-26
### Ajouté
- **Sauvegarde de mes données** (Réglages) : export **JSON complet** (toutes les données,
  restaurable) et export **Journal en CSV** (pour tableur) — à ranger dans votre Drive.

## [2.3.0] — 2026-07-26
### Ajouté
- **Heure de prise** indiquable au moment d'ajouter des aliments (utile notamment pour les encas).
- **Mode Notes & idées** (Réglages → Notes) : prise de notes libres sur l'application,
  en **texte** et/ou en **audio** (enregistrement micro), avec **modification** et **suppression**.
  Audio stocké de façon privée (Supabase Storage). À activer via `supabase/notes.sql`.

## [2.2.7] — 2026-07-26
### Enrichi
- Nouvelle catégorie **🧀 Fromages** : 41 fromages connus (camembert, comté, roquefort,
  reblochon, chèvre, mozzarella, parmesan, cheddar, gorgonzola…) avec valeurs
  nutritionnelles. À charger via `supabase/produits-fromages.sql`.

## [2.2.6] — 2026-07-26
### Enrichi
- Nouvelle catégorie **🥗 Salades** : 27 types (César, niçoise, grecque, chèvre chaud,
  landaise, caprese, salades de pâtes/riz/quinoa/lentilles, crudités…) avec valeurs
  nutritionnelles. À charger via `supabase/produits-salades.sql`.

## [2.2.5] — 2026-07-26
### Enrichi
- Catégorie **Desserts** : ajout de 12 **types de flan** (pâtissier, parisien, caramel,
  vanille, chocolat, coco, café, antillais, espagnol…) avec valeurs nutritionnelles.
  À charger via `supabase/produits-flan.sql`.

## [2.2.4] — 2026-07-26
### Ajouté
- Signature **« By Tadam-3D »** dans l'en-tête de l'application (visible en permanence).
- **Icône** de l'app brandée (wordmark « TADAM-3D ») et **écrans de démarrage (splash)**
  iOS aux couleurs de la marque.

## [2.2.3] — 2026-07-26
### Ajouté
- Signature **« By Tadam-3D »** sur l'écran de connexion et dans les Réglages.

## [2.2.2] — 2026-07-26
### Enrichi
- Nouvelles catégories restaurant : **Italien, Burger & Fast-food, Chinois, Thaïlandais,
  Indien, Mexicain, Libanais / Oriental**, et une catégorie **🍰 Desserts** (classiques :
  tiramisu, fondant, crème brûlée, cheesecake…). 92 produits avec valeurs nutritionnelles.
  À charger via `supabase/produits-restaurant-2.sql`.

## [2.2.1] — 2026-07-26
### Enrichi
- Nouvelles catégories **🍕 Pizzas** (17 classiques de restaurant) et **🍣 Restaurant japonais**
  (29 plats : sushis, makis, sashimis, ramen, gyoza, tempura, yakitori…), avec valeurs
  nutritionnelles. À charger via `supabase/produits-restaurant.sql`.

## [2.2.0] — 2026-07-26
### Ajouté
- **Gestionnaire de produits** (Réglages → Mes produits → Gérer) : liste complète de tous
  les produits avec leurs valeurs nutritionnelles, **recherche**, **modification** de
  n'importe quel produit, et masquer / réafficher.
- **Import / Export CSV** des produits (sauvegarde, édition en masse dans un tableur).
- **Totaux nutritionnels par repas** dans la Journée (kcal, sucre, matières grasses, protéines).
### Note
- Pour modifier les produits du **catalogue par défaut**, exécuter une fois
  `supabase/products-editable.sql` (autorise l'édition du catalogue partagé).

## [2.1.0] — 2026-07-26
### Ajouté — Valeurs nutritionnelles
- Chaque produit porte désormais : **énergie, glucides, dont sucres, matières grasses,
  protéines, sel** (pour 100 g) et un **poids de portion**.
- Catalogue par défaut pré-rempli (~230 produits) avec des moyennes de référence (CIQUAL/ANSES).
- Sélecteur d'aliment : **kcal par portion** affichées, et calcul en direct
  (kcal / sucre / matières grasses) **selon la quantité choisie** (par part).
- Journée : totaux du jour (**kcal ingérées, sucre, matières grasses**).
- Analyses : carte **Nutrition estimée (moyenne/jour)** — kcal, glucides, sucres, MG, protéines, sel.
- Formulaire « nouveau produit » : saisie possible des valeurs nutritionnelles.

## [2.0.0] — 2026-07-26
### Ajouté — Tableau de bord d'analyses (onglet 📊)
- **Aliments à surveiller** : croise vos repas et vos ressentis pour faire ressortir
  les aliments associés à un mauvais état après ingestion.
- **Ce qui vous réussit** : les aliments associés à un bon ressenti.
- **Évolution du ressenti** dans le temps (graphique quotidien coloré).
- **Aliments les plus consommés** et **répartition par catégorie**.
- **Hydratation & boissons** : part des boissons sucrées/gazeuses (levier perte de poids).
- **Symptômes les plus fréquents** et **résumé d'activité physique**.
- Sélecteur de période : 7 / 30 / 90 jours / tout.
### Corrigé
- Service worker en « réseau d'abord » : les mises à jour de l'app arrivent
  désormais immédiatement (plus de version figée en cache).

## [1.2.0] — 2026-07-26
### Ajouté
- **Journal des versions consultable dans l'app** : Réglages → « Voir le journal »
  (ou clic sur le numéro de version). Il est lu directement depuis ce fichier.

## [1.1.0] — 2026-07-26
### Ajouté
- **Sélection multiple d'aliments** : on peut cocher plusieurs produits (même dans
  différentes catégories) et les ajouter d'un seul coup à un repas.
- Quantité réglable **par aliment** dans le panier de sélection (nombre / petite / moyenne / grande).
### Enrichi
- +139 produits préchargés dans le catalogue (≈ 230 aliments au total).

## [1.0.0] — 2026-07-26
### Ajouté (première version — MVP)
- Authentification sécurisée par email + mot de passe (Supabase Auth).
- Sécurité par utilisateur : chaque compte ne voit que ses propres données (RLS PostgreSQL).
- Saisie des repas : petit-déjeuner, déjeuner, dîner et encas, avec heure de prise.
- Choix des aliments depuis un **catalogue français catégorisé** (9 catégories) + saisie libre.
- Quantités : nombre précis, ou taille (petite / moyenne / grande).
- Boissons : eau, thé, café, sucrée, gazeuse, non sucrée, avec nombre de verres.
- Activités physiques : nom, durée, intensité, calories dépensées.
- Bien-être : état de santé après repas (ressenti 1–5, symptômes, heures après ingestion, description).
- Navigation par jour + historique des 14 derniers jours.
- Gestion de ses propres produits dans les réglages.
- Application installable (PWA) sur iPhone, Android, Mac et Windows.
- Design clair et apaisant, responsive mobile et ordinateur.

## [À venir]
- Suivi de la tendance de poids et objectifs.
- Export des données (CSV / PDF).
