-- ============================================================
--  FOOD TRACKER — Rappels configurables (pour les notifications Telegram)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Réexécutable sans risque.
-- ============================================================

create table if not exists public.reminders (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade default auth.uid(),
  kind         text not null default 'custom'
               check (kind in ('petit_dejeuner','dejeuner','diner','encas','poids','custom')),
  label        text not null default 'Rappel',
  emoji        text default '⏰',
  at_time      time not null default '12:00',   -- heure locale (Europe/Paris)
  weekday      int,                             -- null = tous les jours ; 0=dim .. 6=sam (hebdo)
  enabled      boolean not null default true,
  smart        boolean not null default true,   -- n'envoyer que si non saisi (repas) / non pesé (poids)
  message      text,                            -- message personnalisé (optionnel)
  last_sent_on date,                            -- garde d'idempotence (date Paris du dernier envoi)
  sort_order   int default 0,
  created_at   timestamptz default now()
);

create index if not exists reminders_user_idx on public.reminders(user_id);

alter table public.reminders enable row level security;
drop policy if exists reminders_all on public.reminders;
create policy reminders_all on public.reminders
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Contrôle
select count(*) as nb_reminders from public.reminders;
