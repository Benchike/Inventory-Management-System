-- ============================================================
-- PROJECT SITE MANAGER — FINANCE (expenses, deposits, margin)
-- Run once in Supabase → SQL Editor → New query.
-- Safe to re-run.
-- ============================================================

-- Quoted / contract sale price for the project, used as the basis for margin %.
alter table public.project_sites add column if not exists project_cost numeric not null default 0;

-- ---- Expenses: equipment, installer labour, miscellaneous ----
create table if not exists public.project_site_expenses (
  id           uuid primary key default gen_random_uuid(),
  site_id      uuid not null references public.project_sites(id) on delete cascade,
  expense_date date not null default current_date,
  category     text not null default 'Equipment' check (category in ('Equipment','Installer Labour','Miscellaneous')),
  description  text not null default '',
  qty          numeric not null default 1,
  unit_cost    numeric not null default 0,
  amount       numeric not null default 0,
  created_by   text default '',
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);
create index if not exists project_site_expenses_site_idx on public.project_site_expenses (site_id, expense_date desc);

-- ---- Customer deposits ----
create table if not exists public.project_site_deposits (
  id           uuid primary key default gen_random_uuid(),
  site_id      uuid not null references public.project_sites(id) on delete cascade,
  deposit_date date not null default current_date,
  amount       numeric not null default 0,
  method       text default '',
  reference    text default '',
  notes        text default '',
  created_by   text default '',
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);
create index if not exists project_site_deposits_site_idx on public.project_site_deposits (site_id, deposit_date desc);

-- ---- Maintenance calls now also record cost of the visit ----
alter table public.project_site_maintenance add column if not exists cost numeric not null default 0;

-- ---- RLS ----
alter table public.project_site_expenses enable row level security;
alter table public.project_site_deposits enable row level security;
drop policy if exists project_site_expenses_rw on public.project_site_expenses;
drop policy if exists project_site_deposits_rw on public.project_site_deposits;
create policy project_site_expenses_rw on public.project_site_expenses for all to authenticated using (true) with check (true);
create policy project_site_deposits_rw on public.project_site_deposits for all to authenticated using (true) with check (true);

-- ---- Realtime ----
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='project_site_expenses') then
    alter publication supabase_realtime add table public.project_site_expenses;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='project_site_deposits') then
    alter publication supabase_realtime add table public.project_site_deposits;
  end if;
end $$;
