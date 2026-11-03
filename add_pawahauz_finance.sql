-- ============================================================
-- PAWAHAUZ FINANCIAL MODEL — saved scenarios
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================
create table if not exists public.pawahauz_finance_scenarios (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  inputs      jsonb not null default '{}'::jsonb,
  created_by  text default '',
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);
alter table public.pawahauz_finance_scenarios enable row level security;
drop policy if exists pwf_scenarios_rw on public.pawahauz_finance_scenarios;
create policy pwf_scenarios_rw on public.pawahauz_finance_scenarios for all to authenticated using (true) with check (true);
