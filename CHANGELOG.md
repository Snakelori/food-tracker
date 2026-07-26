# Journal des versions

Toutes les évolutions notables de l'application sont consignées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/).

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

## [À venir] — Version 2
- Tableau de bord de statistiques : corrélations aliments ↔ bien-être.
- Identification des aliments à éviter et de ceux qui vous réussissent.
- Suivi de la tendance de poids et objectifs.
- Export des données (CSV / PDF).
