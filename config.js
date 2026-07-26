// ============================================================
//  CONFIGURATION SUPABASE
//  Remplacez les deux valeurs ci-dessous par celles de VOTRE
//  projet Supabase :  Settings > API
//    - Project URL         ->  SUPABASE_URL
//    - Project API keys > anon public  ->  SUPABASE_ANON_KEY
//
//  ⚠️  La clé "anon public" est conçue pour être publique côté
//      navigateur. Vos données restent protégées par la RLS
//      (Row Level Security) définie dans supabase/schema.sql.
//      Ne mettez JAMAIS la clé "service_role" ici.
// ============================================================
window.APP_CONFIG = {
  SUPABASE_URL: "https://VOTRE-PROJET.supabase.co",
  SUPABASE_ANON_KEY: "VOTRE_CLE_ANON_PUBLIC",
  APP_VERSION: "1.0.0"
};
