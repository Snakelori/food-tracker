# 💾 Sauvegarde automatique du code vers Google Drive

Le workflow [`.github/workflows/backup-drive.yml`](../.github/workflows/backup-drive.yml)
archive tout le projet et l'envoie dans **votre** Google Drive **à chaque push sur `main`**,
**chaque lundi**, et **à la demande**. Il utilise [rclone](https://rclone.org) (open-source)
connecté à **votre propre compte Google** (OAuth) : les fichiers vous appartiennent, dans
votre Drive, **aucun partage à configurer**.

> ⚠️ Vous seul manipulez le jeton : il est collé dans les *Secrets* GitHub (chiffrés).

## Configuration (une seule fois, ~10 min)

### 1. Installer rclone sur votre Mac
Dans le Terminal :
```bash
brew install rclone
```
*(Sans Homebrew : `curl https://rclone.org/install.sh | sudo bash`.)*

### 2. Générer le jeton d'accès à votre Drive
```bash
rclone authorize "drive"
```
- Une page Google s'ouvre dans le navigateur → **connectez-vous à votre compte** → **Autoriser**.
  *(Si un écran « application non vérifiée » apparaît : Paramètres avancés → Continuer — c'est rclone.)*
- De retour dans le Terminal, rclone affiche un **jeton** entre deux repères :
  ```
  Paste the following into your remote machine --->
  {"access_token":"…","refresh_token":"…","expiry":"…"}
  <---End paste
  ```
- **Copiez toute la ligne** `{ … }` (le jeton JSON).

### 3. Préparer le dossier de destination (dans VOTRE Drive)
1. Dans [Google Drive](https://drive.google.com), créez un dossier, ex. **Sauvegardes Food-Tracker**.
2. Ouvrez-le ; dans l'URL, copiez l'**ID du dossier** :
   `https://drive.google.com/drive/folders/`**`CET_IDENTIFIANT`**

### 4. Ajouter les secrets sur GitHub
Sur `github.com/Snakelori/food-tracker` → **Settings → Secrets and variables → Actions → New repository secret** :

| Nom du secret          | Valeur                                          |
|------------------------|-------------------------------------------------|
| `GDRIVE_RCLONE_TOKEN`  | Le **jeton JSON** copié à l'étape 2 (`{ … }`)   |
| `GDRIVE_FOLDER_ID`     | L'**ID du dossier** (étape 3)                   |

> Si vous aviez créé un ancien secret `GDRIVE_SA_JSON` (méthode compte de service), vous
> pouvez le **supprimer** : il n'est plus utilisé.

### 5. Tester
- Onglet **Actions** → **Sauvegarde vers Google Drive** → **Run workflow**.
- Après ~1 min, `food-tracker-AAAA-MM-JJ.zip` apparaît dans votre dossier Drive. ✅

## Bon à savoir
- Tant que les secrets ne sont pas configurés, le workflow s'exécute **sans erreur** mais
  saute l'envoi (avertissement dans le log).
- Les archives portent la **date du jour** ; le cron du lundi garde un instantané hebdomadaire.

---

# 🗄️ Sauvegarde automatique de la BASE DE DONNÉES

Le workflow [`.github/workflows/db-backup-drive.yml`](../.github/workflows/db-backup-drive.yml)
fait un **`pg_dump`** de votre base Supabase **chaque jour** (02:00 UTC) et l'envoie sur
votre Drive (sous-dossier `base-de-donnees/`, à côté des sauvegardes du code).

## Configuration (une seule fois)

### 1. Récupérer la chaîne de connexion
1. Dans votre projet Supabase → **Settings → Database → Connection string**.
2. Choisissez l'onglet **Session pooler** (ou **Direct connection**) — **PAS** « Transaction pooler »
   (incompatible avec `pg_dump`).
3. Format **URI** : copiez la ligne `postgresql://postgres.[...]:[YOUR-PASSWORD]@...:5432/postgres`.
4. Remplacez `[YOUR-PASSWORD]` par le **mot de passe de votre base**
   *(oublié ? Settings → Database → Reset database password)*.

### 2. Ajouter le secret sur GitHub
**Settings → Secrets and variables → Actions → New repository secret** :

| Nom du secret       | Valeur                                   |
|---------------------|------------------------------------------|
| `SUPABASE_DB_URL`   | La chaîne de connexion complète (étape 1) |

*(Le jeton `GDRIVE_RCLONE_TOKEN` déjà en place est réutilisé pour l'envoi.)*

### 3. Tester
- Onglet **Actions** → **Sauvegarde base de données vers Drive** → **Run workflow**.
- Après ~1 min, `food-db-AAAA-MM-JJ.sql.gz` apparaît dans `base-de-donnees/` sur le Drive. ✅

## Restaurer (en cas de besoin)
```bash
gunzip food-db-AAAA-MM-JJ.sql.gz
psql "VOTRE_CHAINE_DE_CONNEXION" -f food-db-AAAA-MM-JJ.sql
```

## Bon à savoir
- Sauvegarde le **schéma `public`** (vos données : repas, produits, notes, etc.).
- **Non inclus** : les fichiers **audio** des notes (stockés dans Supabase Storage) et les
  **comptes** (gérés par Supabase Auth). Pour les données applicatives courantes, c'est couvert.
- Pour une copie ponctuelle « à la main », l'export *Réglages → 💾 Sauvegarde de mes données*
  (JSON) reste disponible dans l'app.
