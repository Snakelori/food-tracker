# 🔔 Rappels de saisie par Telegram

Recevez un message Telegram pour penser à saisir vos repas / vous peser.

Les horaires et les rappels sont **configurables directement dans l'app** :
**Réglages → 🔔 Rappels de saisie → Gérer**. Vous pouvez :

- changer l'**heure** de chaque rappel (petit-déj, déjeuner, dîner) ;
- **activer** un rappel **encas** et une **pesée hebdomadaire** (jour + heure au choix) ;
- **ajouter** vos propres rappels personnalisés ;
- activer/désactiver chacun, et choisir le mode **🧠 Intelligent**.

> 🧠 **Intelligent** = le message n'est envoyé **que si** le repas n'est pas déjà saisi
> ce jour-là (ou, pour la pesée, si vous ne vous êtes pas pesé cette semaine).

Techniquement : les réglages sont stockés dans la table `public.reminders` (Supabase),
et le workflow GitHub Actions
[`.github/workflows/rappels-telegram.yml`](../.github/workflows/rappels-telegram.yml)
tourne **toutes les 15 min**, lit les rappels dus et envoie ceux qui doivent l'être
(une garde anti-doublon garantit un envoi au plus par jour et par rappel).
Il réutilise le secret `SUPABASE_DB_URL` déjà en place pour la sauvegarde de la base.

## Prérequis Supabase

Exécuter une fois, dans **Supabase → SQL Editor**, le script
[`supabase/rappels.sql`](../supabase/rappels.sql) (crée la table `reminders`).
Les rappels par défaut se créent tout seuls à la première ouverture de l'écran Rappels.

---

## Étape 1 — Créer le bot Telegram (2 min)

1. Dans Telegram, ouvrez une conversation avec **@BotFather**.
2. Envoyez `/newbot`, choisissez un **nom** (ex. *Rappels Journal*) puis un **identifiant**
   se terminant par `bot` (ex. `journal_olivier_bot`).
3. BotFather vous répond avec un **token** du type
   `123456789:AAExxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`.
   👉 C'est votre `TELEGRAM_BOT_TOKEN`. Gardez-le au chaud.

## Étape 2 — Démarrer une conversation avec votre bot

1. Toujours dans Telegram, ouvrez votre nouveau bot (cliquez sur le lien donné par BotFather).
2. Cliquez sur **Démarrer** / envoyez `/start`.
   > ⚠️ Indispensable : un bot ne peut pas vous écrire tant que vous ne lui avez pas parlé.

## Étape 3 — Récupérer votre `chat_id`

1. Dans un navigateur, ouvrez cette adresse (remplacez `VOTRE_TOKEN`) :
   ```
   https://api.telegram.org/botVOTRE_TOKEN/getUpdates
   ```
2. Cherchez dans la réponse : `"chat":{"id":123456789,...}`.
   👉 Ce nombre est votre `TELEGRAM_CHAT_ID`.

   *(Si la réponse est vide `{"ok":true,"result":[]}`, renvoyez un message à votre bot
   dans Telegram puis rechargez la page.)*

## Étape 4 — Ajouter les 2 secrets sur GitHub

Sur le dépôt : **Settings → Secrets and variables → Actions → New repository secret**.
Créez ces deux secrets :

| Nom | Valeur |
|---|---|
| `TELEGRAM_BOT_TOKEN` | le token de l'étape 1 |
| `TELEGRAM_CHAT_ID`   | le nombre de l'étape 3 |

*(Le secret `SUPABASE_DB_URL` est déjà présent — rien à refaire.)*

## Étape 5 — Tester tout de suite

Sur GitHub : onglet **Actions → « Rappels de saisie (Telegram) » → Run workflow**,
cochez **test = true**, puis **Run**.
Vous devez recevoir dans les secondes qui suivent :
> ✅ Test OK — les rappels Telegram de ton Journal Alimentaire fonctionnent ! 🥗

Si oui, c'est bon : les rappels intelligents s'enverront automatiquement aux heures prévues. 🎉

---

## Régler / changer les heures

Tout se fait dans l'app : **Réglages → 🔔 Rappels de saisie → Gérer**.
(Plus besoin de toucher au fichier du workflow.) Le workflow interroge vos réglages
toutes les 15 min ; un rappel réglé à 09h30 part donc entre 09h30 et ~09h45.

## Dépannage

- **Aucun message de test** : token ou chat_id erroné, ou vous n'avez pas fait `/start`.
- **`getUpdates` vide** : envoyez un message au bot puis rechargez la page.
- Les crons GitHub peuvent avoir **quelques minutes de retard** (normal).
