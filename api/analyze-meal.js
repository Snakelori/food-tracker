// ============================================================
//  Fonction serverless Vercel — Analyse d'une photo de repas
//  Appelle l'API Claude (Anthropic) en gardant la clé CÔTÉ SERVEUR.
//  Variables d'environnement Vercel :
//    - ANTHROPIC_API_KEY  (obligatoire)
//    - ANTHROPIC_MODEL    (optionnel, défaut claude-sonnet-5 ;
//                          mettez "claude-opus-5" pour plus de précision)
// ============================================================

const MODEL = process.env.ANTHROPIC_MODEL || "claude-sonnet-5";

const SYSTEM = `Tu es un nutritionniste. On te fournit la PHOTO d'un repas.
Identifie chaque aliment/plat visible et estime, pour la PORTION visible (pas pour 100 g),
ses valeurs nutritionnelles.
Réponds UNIQUEMENT par un objet JSON valide, sans aucun texte autour, de la forme :
{"items":[{"name":"...","emoji":"🍽️","grams":<entier g estimés>,"kcal":<entier>,"carb_g":<nombre>,"sugar_g":<nombre>,"fat_g":<nombre>,"protein_g":<nombre>,"salt_g":<nombre>,"confidence":<0..1>}]}
Règles : noms courts en français ; un item par aliment distinct ; valeurs pour la portion
visible ; si l'image n'est pas de la nourriture, renvoie {"items":[]}.`;

module.exports = async (req, res) => {
  if (req.method !== "POST") { res.status(405).json({ error: "Méthode non autorisée" }); return; }
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) { res.status(500).json({ error: "ANTHROPIC_API_KEY manquante (variable d'environnement Vercel)." }); return; }

  try {
    let body = req.body;
    if (typeof body === "string") { try { body = JSON.parse(body); } catch { body = {}; } }
    let image = body && body.image;
    let media_type = body && body.media_type;
    if (!image) { res.status(400).json({ error: "Aucune image fournie." }); return; }

    // Retirer le préfixe data:URL éventuel
    const m = /^data:(image\/[a-zA-Z0-9.+-]+);base64,(.*)$/.exec(image);
    if (m) { media_type = m[1]; image = m[2]; }
    media_type = media_type || "image/jpeg";

    const r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": key,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 1024,
        system: SYSTEM,
        messages: [{
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type, data: image } },
            { type: "text", text: "Analyse ce repas et renvoie le JSON demandé." },
          ],
        }],
      }),
    });

    if (!r.ok) {
      const t = await r.text();
      res.status(502).json({ error: "Erreur API Claude", detail: t.slice(0, 400) });
      return;
    }

    const j = await r.json();
    const text = (j.content || []).filter(b => b.type === "text").map(b => b.text).join("");
    const match = text.match(/\{[\s\S]*\}/);
    let parsed = { items: [] };
    try { parsed = JSON.parse(match ? match[0] : text); } catch { /* JSON introuvable */ }
    const items = Array.isArray(parsed.items) ? parsed.items.slice(0, 20) : [];
    res.status(200).json({ items, model: MODEL });
  } catch (e) {
    res.status(500).json({ error: String((e && e.message) || e) });
  }
};
