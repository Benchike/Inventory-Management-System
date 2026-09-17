-- ============================================================
-- PROJECT SITE MANAGER — SINGLE MEDIA LINK
-- Collapses the pre/post-installation media link fields into one
-- link covering all photos/videos for the site. The old
-- pre_install_media_link / post_install_media_link columns (and the
-- original pre_install_photos / post_install_photos jsonb columns
-- before them) are left in place, unused, so no data is lost.
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

alter table public.project_sites add column if not exists media_link text default '';
