# 💾 Sauvegarde automatique du code vers Google Drive

Le workflow [`.github/workflows/backup-drive.yml`](../.github/workflows/backup-drive.yml)
archive tout le projet et l'envoie sur un dossier Google Drive **à chaque push sur `main`**,
**chaque lundi**, et **à la demande**. Il utilise [rclone](https://rclone.org) (open-source)
avec un **compte de service Google** — vous gardez le contrôle total des accès.

> ⚠️ Vous êtes seul à manipuler les identifiants : ils sont collés dans les *Secrets* GitHub,
> jamais partagés ailleurs.

## Configuration (une seule fois, ~10 min)

### 1. Activer l'API Google Drive
1. Ouvrez [console.cloud.google.com](https://console.cloud.google.com).
2. Créez (ou choisissez) un projet.
3. Menu **APIs & Services → Library** → cherchez **Google Drive API** → **Enable**.

### 2. Créer un compte de service + clé
1. **APIs & Services → Credentials → Create credentials → Service account**.
2. Donnez un nom (ex. `backup-food-tracker`) → **Create and continue** → **Done**.
3. Cliquez sur le compte de service créé → onglet **Keys → Add key → Create new key → JSON**.
4. Un fichier `.json` se télécharge : gardez-le, c'est la clé.
5. Notez l'**adresse e-mail** du compte de service (finit par `…iam.gserviceaccount.com`).

### 3. Préparer le dossier Drive
1. Dans [Google Drive](https://drive.google.com), créez un dossier, ex. **Sauvegardes Food-Tracker**.
2. Clic droit → **Partager** → collez l'**e-mail du compte de service** → rôle **Éditeur** → Envoyer.
3. Ouvrez le dossier ; dans l'URL, copiez l'**ID du dossier** :
   `https://drive.google.com/drive/folders/`**`CET_IDENTIFIANT`**

### 4. Ajouter les secrets sur GitHub
Sur `github.com/Snakelori/food-tracker` → **Settings → Secrets and variables → Actions → New repository secret** :

| Nom du secret        | Valeur                                              |
|----------------------|-----------------------------------------------------|
| `GDRIVE_SA_JSON`     | **Tout le contenu** du fichier `.json` téléchargé   |
| `GDRIVE_FOLDER_ID`   | L'ID du dossier Drive (étape 3)                     |

### 5. Tester
- Onglet **Actions** du dépôt → workflow **« Sauvegarde vers Google Drive »** → **Run workflow**.
- Après ~1 min, un fichier `food-tracker-AAAA-MM-JJ.zip` apparaît dans votre dossier Drive. ✅

## Bon à savoir
- Tant que les secrets ne sont pas configurés, le workflow s'exécute **sans erreur** mais
  saute simplement l'envoi (un avertissement l'indique).
- Les archives portent la **date du jour** : plusieurs push le même jour écrasent le fichier
  du jour ; le cron du lundi garde un instantané hebdomadaire.
- Ceci sauvegarde le **code**. Pour les **données** (repas, notes…), utilisez
  *Réglages → 💾 Sauvegarde de mes données* dans l'app (export JSON à ranger sur le Drive).
