-- ============================================================
--  FOOD TRACKER — Bien-être : champ « état général » (multi-choix)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Réexécutable sans risque.
-- ============================================================

alter table public.health_states
  add column if not exists general_state text[];
