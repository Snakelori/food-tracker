-- ============================================================
--  FOOD TRACKER — Suivi du poids & objectifs
--  À exécuter dans : Supabase > SQL Editor > New query > Run
-- ============================================================

-- Pesées (une par jour, mise à jour si re-pesée le même jour)
create table if not exists public.weights (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade default auth.uid(),
  log_date   date not null default current_date,
  weight_kg  numeric not null,
  created_at timestamptz default now(),
  unique (user_id, log_date)
);
create index if not exists weights_user_date_idx on public.weights(user_id, log_date);

alter table public.weights enable row level security;
drop policy if exists weights_all on public.weights;
create policy weights_all on public.weights
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Objectifs (une ligne par utilisateur)
create table if not exists public.user_goals (
  user_id          uuid primary key references auth.users(id) on delete cascade default auth.uid(),
  target_weight_kg numeric,
  start_weight_kg  numeric,
  height_cm        numeric,
  daily_kcal_goal  int,
  updated_at       timestamptz default now()
);

alter table public.user_goals enable row level security;
drop policy if exists user_goals_all on public.user_goals;
create policy user_goals_all on public.user_goals
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
