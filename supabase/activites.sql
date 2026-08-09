-- ============================================================
--  FOOD TRACKER — Activités : durée précise en secondes
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Réexécutable sans risque.
-- ============================================================

-- Durée précise (hh:mm:ss) — duration_min est conservé pour compatibilité.
alter table public.activities
  add column if not exists duration_sec int;

-- Renseigner duration_sec pour les activités existantes (à partir des minutes).
update public.activities
  set duration_sec = duration_min * 60
  where duration_sec is null and duration_min is not null;
