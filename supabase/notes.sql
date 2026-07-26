-- ============================================================
--  FOOD TRACKER — Notes (texte + audio)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--  Crée la table des notes, la sécurité RLS, et un bucket de
--  stockage privé pour les notes audio.
-- ============================================================

-- 1) Table des notes
create table if not exists public.notes (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade default auth.uid(),
  content     text,
  audio_path  text,        -- chemin du fichier audio dans le bucket
  audio_mime  text,        -- type MIME de l'audio
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);
create index if not exists notes_user_idx on public.notes(user_id, created_at desc);

alter table public.notes enable row level security;
drop policy if exists notes_all on public.notes;
create policy notes_all on public.notes
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 2) Bucket de stockage privé pour l'audio des notes
insert into storage.buckets (id, name, public)
values ('notes-audio', 'notes-audio', false)
on conflict (id) do nothing;

-- 3) Sécurité du stockage : chacun gère uniquement ses fichiers
drop policy if exists notes_audio_insert on storage.objects;
create policy notes_audio_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'notes-audio' and owner = auth.uid());

drop policy if exists notes_audio_select on storage.objects;
create policy notes_audio_select on storage.objects
  for select to authenticated
  using (bucket_id = 'notes-audio' and owner = auth.uid());

drop policy if exists notes_audio_delete on storage.objects;
create policy notes_audio_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'notes-audio' and owner = auth.uid());
