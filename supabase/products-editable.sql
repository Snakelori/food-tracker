-- ============================================================
--  FOOD TRACKER — Autoriser la modification du catalogue
--  À exécuter dans : Supabase > SQL Editor > New query > Run
--
--  Par défaut, seuls VOS produits perso (user_id = vous) étaient
--  modifiables. Cette règle autorise aussi la modification des
--  produits du catalogue partagé (user_id NULL) — utile pour
--  ajuster les valeurs nutritionnelles depuis l'application.
--  (Sans risque sur une base personnelle mono-utilisateur.)
-- ============================================================

drop policy if exists products_update on public.products;
create policy products_update on public.products
  for update to authenticated
  using (user_id is null or user_id = auth.uid())
  with check (user_id is null or user_id = auth.uid());
