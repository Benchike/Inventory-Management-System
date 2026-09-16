-- ============================================================
-- PROJECT SITE MANAGER — MEDIA LINKS
-- Replaces uploaded pre/post-installation photo galleries with a
-- single shared media link per stage (e.g. a Google Drive folder).
-- The old pre_install_photos / post_install_photos jsonb columns are
-- left in place (unused) so no existing photo data is lost.
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

alter table public.project_sites add column if not exists pre_install_media_link  text default '';
alter table public.project_sites add column if not exists post_install_media_link text default '';
