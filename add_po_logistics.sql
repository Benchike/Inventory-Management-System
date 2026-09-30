-- ============================================================
-- PURCHASE ORDERS — ADD LOGISTICS COSTS
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- Stores itemized logistics as [{ "desc": "...", "amount": 0 }].
-- ============================================================

alter table public.documents     add column if not exists logistics jsonb not null default '[]'::jsonb;
alter table public.lif_documents add column if not exists logistics jsonb not null default '[]'::jsonb;
