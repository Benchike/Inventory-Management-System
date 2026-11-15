-- ============================================================
-- RECEIPT GENERATOR — EDITABLE TERMS & CONDITIONS
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- NULL = receipt uses the default terms; '' = terms hidden.
-- ============================================================

alter table public.receipts add column if not exists terms_conditions text;
