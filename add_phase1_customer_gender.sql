-- ============================================================
-- LIF DEPLOYMENT REPORT — CUSTOMER GENDER
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

alter table public.lif_phase1_installations add column if not exists gender text not null default '';
