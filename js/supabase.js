// Initialise le client Supabase (chargé depuis le CDN dans index.html)
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cfg = window.APP_CONFIG || {};

if (!cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes("VOTRE-PROJET")) {
  console.warn("⚠️ config.js n'est pas encore renseigné avec vos identifiants Supabase.");
}

export const supabase = createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true }
});

export const isConfigured = () =>
  cfg.SUPABASE_URL && !cfg.SUPABASE_URL.includes("VOTRE-PROJET") &&
  cfg.SUPABASE_ANON_KEY && !cfg.SUPABASE_ANON_KEY.includes("VOTRE_CLE");
