create table if not exists public.sales_targets (
  id              uuid primary key default gen_random_uuid(),
  period          text not null unique,
  net_margin      numeric not null default 15,
  deal_size       numeric not null default 2500000,
  reps            integer not null default 3,
  work_days       integer not null default 24,
  fixed_costs     jsonb not null default '[]'::jsonb,
  variable_costs  jsonb not null default '[]'::jsonb,
  created_by      text default '',
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

create index if not exists sales_targets_updated_idx on public.sales_targets (updated_at desc);

alter table public.sales_targets enable row level security;
drop policy if exists sales_targets_rw on public.sales_targets;
create policy sales_targets_rw on public.sales_targets for all to authenticated using (true) with check (true);
