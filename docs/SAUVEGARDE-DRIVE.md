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
- Ceci sauvegarde le **code**. Pour les **données** (repas, notes…), utilisez
  *Réglages → 💾 Sauvegarde de mes données* dans l'app (export JSON à ranger sur le Drive).
