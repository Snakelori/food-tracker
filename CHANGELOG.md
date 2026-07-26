# Journal des versions

Toutes les évolutions notables de l'application sont consignées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/).

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
