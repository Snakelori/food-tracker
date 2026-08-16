-- ============================================================
--  FOOD TRACKER — Objectifs de macronutriments
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Réexécutable sans risque.
-- ============================================================

alter table public.user_goals
  add column if not exists protein_g_goal int,
  add column if not exists carb_g_goal    int,
  add column if not exists fat_g_goal      int;
