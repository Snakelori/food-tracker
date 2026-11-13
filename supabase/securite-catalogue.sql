-- ============================================================
--  FOOD TRACKER — Sécurisation du catalogue partagé (v2.10.6)
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--
--  Remplace la règle de products-editable.sql, qui autorisait
--  N'IMPORTE QUEL compte connecté à modifier le catalogue partagé.
--  Désormais : seul VOTRE compte peut modifier les produits
--  partagés (user_id NULL) ; chacun garde la main sur ses produits.
--
--  ⚠️ Remplacez VOTRE-UID ci-dessous par votre identifiant :
--     Authentication > Users > votre ligne > UID
-- ============================================================

drop policy if exists products_update on public.products;
create policy products_update on public.products
  for update to authenticated
  using (
    user_id = auth.uid()
    or (user_id is null and auth.uid() = '6a4bb730-0031-4fd3-b1ee-f00d7519eb26'::uuid)
  )
  with check (
    user_id = auth.uid()
    or (user_id is null and auth.uid() = '6a4bb730-0031-4fd3-b1ee-f00d7519eb26'::uuid)
  );
