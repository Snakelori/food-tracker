# Journal des versions

Toutes les évolutions notables de l'application sont consignées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/).

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
