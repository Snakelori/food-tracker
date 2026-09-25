# 📸 Analyse d'un repas par photo (Claude vision)

Prenez une photo de votre assiette → l'IA (Claude d'Anthropic) identifie les aliments et
estime leurs valeurs nutritionnelles → vous validez → c'est ajouté au repas.

- Bouton **« 📸 Analyser une photo du repas »** dans l'ajout d'aliment.
- La clé API reste **côté serveur** (fonction Vercel `api/analyze-meal.js`) — jamais dans le navigateur.
- La photo est envoyée à Anthropic pour analyse puis **non stockée**.

---

## Étape 1 — Créer une clé API Anthropic (~2 min)

1. Allez sur **https://console.anthropic.com** et connectez-vous (ou créez un compte).
2. **Billing → Add credits** : ajoutez un petit crédit (ex. 5 $). Chaque photo coûte
   ~**1 centime** (modèle Claude Sonnet).
3. **API Keys → Create Key** : copiez la clé (commence par `sk-ant-...`).

## Étape 2 — Ajouter la clé dans Vercel

1. Ouvrez votre projet sur **https://vercel.com** → **Settings → Environment Variables**.
2. Ajoutez :

   | Name | Value |
   |---|---|
   | `ANTHROPIC_API_KEY` | votre clé `sk-ant-...` |

   *(Optionnel)* pour plus de précision, ajoutez aussi `ANTHROPIC_MODEL` = `claude-opus-5`
   (plus cher, ~2–3 centimes/photo). Sinon le défaut `claude-sonnet-5` est parfait.
3. Cochez les 3 environnements (Production/Preview/Development) puis **Save**.

## Étape 3 — Redéployer

La variable n'est prise en compte qu'après un redéploiement :
- Poussez n'importe quel commit, **ou**
- Vercel → onglet **Deployments** → dernier déploiement → **⋯ → Redeploy**.

## Étape 4 — Tester

Dans l'app : ajoutez un aliment → **📸 Analyser une photo** → prenez une photo d'un plat →
l'app propose la liste des aliments détectés → cochez ce qui est juste → **Ajouter au repas**.

---

## Bon à savoir

- **Coût** : à votre charge, sur votre compte Anthropic. ~1 centime/photo en Sonnet.
  Vous pouvez fixer une **limite de dépense** dans la console Anthropic (Billing → Limits).
- **Précision** : très bon pour **identifier** les plats, plus **approximatif** sur les
  quantités/calories → l'app pré-remplit, vous ajustez ensuite (✏️ sur chaque aliment).
- **Aliments connus** : si un aliment détecté existe déjà à l'identique dans votre catalogue,
  l'app réutilise ses valeurs ; sinon elle crée un nouvel aliment (emoji 📸) avec l'estimation.
- **Confidentialité** : la photo transite par Anthropic le temps de l'analyse, sans stockage.
- ⚠️ Ne fonctionne **pas en aperçu local** (pas de fonction serveur) — uniquement sur le site
  déployé (Vercel).
