-- ============================================================
-- PROJECT SITE EXPENSES — ALLOW "LOT" AS QTY
-- Converts qty from numeric to text so entries like "Lot" (for
-- non-quantifiable costs) can be stored alongside plain numbers.
-- Existing numeric values are cast to text automatically.
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

alter table public.project_site_expenses
  alter column qty type text using qty::text,
  alter column qty set default '1';
