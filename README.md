# 🥗 Mon Journal Alimentaire

Application web sécurisée pour enregistrer chaque jour ses repas, boissons, encas,
activités physiques et son état de santé — afin d'identifier ce qui n'aide pas à la
perte de poids et les aliments à éviter.

Accessible depuis **n'importe quelle plateforme** (Mac, Windows, iPhone, Android) via
un simple navigateur, et **installable** en application (PWA).

- **Frontend** : HTML / CSS / JavaScript (vanilla, aucun build).
- **Backend** : [Supabase](https://supabase.com) (base PostgreSQL + authentification + RLS).
- **Hébergement** : [Vercel](https://vercel.com) (fichiers statiques).

---

## 🚀 Mise en route (3 étapes)

### 1. Créer la base de données Supabase
1. Sur [supabase.com](https://supabase.com), créez un projet (notez le mot de passe de la base).
2. Menu **SQL Editor** → **New query** → collez tout le contenu de
   [`supabase/schema.sql`](supabase/schema.sql) → **Run**.
   Cela crée les tables, la sécurité (RLS) et le catalogue de produits français.
3. Menu **Authentication → Providers → Email** : laissez « Email » activé.
   *(Optionnel : désactivez « Confirm email » pour vous connecter sans validation par mail.)*

### 2. Renseigner vos identifiants
1. Menu **Project Settings → API**.
2. Copiez **Project URL** et la clé **anon public**.
3. Collez-les dans [`config.js`](config.js) à la place des valeurs `VOTRE-…`.
   > La clé *anon public* est faite pour être publique ; vos données restent protégées par la RLS.
   > Ne mettez **jamais** la clé `service_role` ici.

### 3. Déployer
**Option A — Vercel + GitHub (recommandé)**
1. Poussez ce dossier sur un dépôt GitHub.
2. Sur Vercel : **Add New → Project → Import** votre dépôt.
3. Framework Preset : **Other** (rien à configurer, c'est du statique). **Deploy**.
4. Ouvrez l'URL fournie → créez votre compte → c'est prêt.

**Option B — Test en local**
```bash
cd food-tracker
python3 -m http.server 5173
```
Puis ouvrez http://localhost:5173

---

## 📱 Installer sur le téléphone
- **iPhone (Safari)** : bouton *Partager* → *Sur l'écran d'accueil*.
- **Android (Chrome)** : menu ⋮ → *Installer l'application*.
- **Ordinateur** : icône d'installation dans la barre d'adresse.

---

## 🔒 Sécurité
- Accès protégé par authentification (email + mot de passe).
- **Row Level Security** activée sur toutes les tables : un utilisateur ne peut lire ou
  modifier que ses propres données, même en cas de tentative d'accès direct à l'API.
- Aucune donnée sensible (clé `service_role`) n'est exposée côté navigateur.

---

## 🗂️ Structure du projet
```
food-tracker/
├── index.html              Coquille de l'application
├── config.js               Vos identifiants Supabase (à renseigner)
├── manifest.webmanifest    Métadonnées PWA
├── sw.js                   Service worker (cache hors-ligne)
├── vercel.json             Config Vercel (headers de sécurité)
├── css/styles.css          Design
├── js/
│   ├── app.js              Logique applicative
│   └── supabase.js         Client Supabase
├── assets/                 Icône et images
└── supabase/schema.sql     Base de données (à exécuter une fois)
```

## 🧭 Versionnement
Les évolutions sont suivies dans [`CHANGELOG.md`](CHANGELOG.md) et via l'historique Git.
Version actuelle : **1.0.0**.
