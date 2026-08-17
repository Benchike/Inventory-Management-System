-- ============================================================
-- Kiru Energy — Platform Schema
-- Two independent inventory systems:
--   "company"  →  items / documents / counters
--   "lif"      →  lif_items / lif_documents / lif_counters
--
-- Run once (or re-run) in Supabase → SQL Editor → New query.
-- All statements use IF NOT EXISTS / OR REPLACE so they are safe to re-run.
-- ============================================================

-- ============================================================
-- COMPANY INVENTORY
-- ============================================================

create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  sku         text default '',
  category    text default '',
  unit        text default 'Unit',
  qty         numeric default 0,
  cost        numeric default 0,
  reorder     numeric default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table if not exists public.documents (
  id             uuid primary key default gen_random_uuid(),
  kind           text not null check (kind in ('po','mro')),
  no             text not null,
  doc_date       date not null default current_date,
  status         text not null default 'draft',
  supplier       text default '',
  requested_by   text default '',
  project        text default '',
  note           text default '',
  lines          jsonb not null default '[]'::jsonb,
  prepared_by    text default '',
  approved_by    text default '',
  approver_title text default '',
  signature      text default '',
  applied_date   date,
  payment_receipt text default '',
  purpose        text default '',
  created_by     text default '',
  created_at     timestamptz default now()
);

-- Safe column additions for existing deployments
alter table public.documents add column if not exists payment_receipt text default '';
alter table public.documents add column if not exists purpose text default '';

create table if not exists public.counters (
  kind  text primary key,
  value integer not null default 0
);
insert into public.counters (kind, value) values ('po',0), ('mro',0)
  on conflict (kind) do nothing;

create index if not exists documents_kind_idx on public.documents (kind, created_at desc);

create table if not exists public.bos_packages (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text default '',
  components  jsonb not null default '[]'::jsonb,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.bos_packages enable row level security;
drop policy if exists bos_packages_rw on public.bos_packages;
create policy bos_packages_rw on public.bos_packages for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'bos_packages'
  ) then
    alter publication supabase_realtime add table public.bos_packages;
  end if;
end $$;

-- ============================================================
-- COMPANY INVOICING
-- ============================================================

create table if not exists public.invoices (
  id            uuid primary key default gen_random_uuid(),
  inv_no        text not null unique,
  inv_date      date not null default current_date,
  due_date      date,
  client_name   text default '',
  client_addr   text default '',
  panel_name    text default '',
  panel_cap     numeric default 0,
  panel_qty     numeric default 0,
  panel_price   numeric default 0,
  inv_name      text default '',
  inv_cap       numeric default 0,
  inv_qty       numeric default 0,
  inv_price     numeric default 0,
  batt_name     text default '',
  batt_cap      numeric default 0,
  batt_qty      numeric default 0,
  batt_price    numeric default 0,
  add_items     jsonb not null default '[]'::jsonb,
  total_amt     numeric not null default 0,
  bank_name       text default 'Wema Bank',
  account_name    text default 'Kiru Energy Ltd',
  account_number  text default '127429081',
  sign_name       text default 'Chidi Okoronkwo',
  sign_title      text default 'Head of Sales',
  signature       text default '',
  status        text not null default 'draft' check (status in ('draft','issued')),
  issued_at     timestamptz,
  created_by    text default '',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- Safe column additions for existing deployments
alter table public.invoices add column if not exists bank_name      text default 'Wema Bank';
alter table public.invoices add column if not exists account_name   text default 'Kiru Energy Ltd';
alter table public.invoices add column if not exists account_number text default '127429081';
alter table public.invoices add column if not exists sign_name      text default 'Chidi Okoronkwo';
alter table public.invoices add column if not exists sign_title     text default 'Head of Sales';
alter table public.invoices add column if not exists signature      text default '';
alter table public.invoices add column if not exists panel_price    numeric default 0;
alter table public.invoices add column if not exists inv_price      numeric default 0;
alter table public.invoices add column if not exists batt_price     numeric default 0;
alter table public.invoices add column if not exists panel_name     text default '';
alter table public.invoices add column if not exists inv_name       text default '';
alter table public.invoices add column if not exists batt_name      text default '';

create index if not exists invoices_status_idx on public.invoices (status, created_at desc);

create table if not exists public.invoice_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_invoice_no()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.invoice_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.invoice_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-INV-' || dkey || '-' || lpad(v::text, 4, '0');
end $$;

alter table public.invoices          enable row level security;
alter table public.invoice_counters  enable row level security;
drop policy if exists invoices_rw         on public.invoices;
drop policy if exists invoice_counters_r  on public.invoice_counters;
create policy invoices_rw         on public.invoices          for all    to authenticated using (true) with check (true);
create policy invoice_counters_r  on public.invoice_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'invoices'
  ) then
    alter publication supabase_realtime add table public.invoices;
  end if;
end $$;

-- ============================================================
-- COMPANY TASK TRACKER
-- ============================================================

create table if not exists public.tasks (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  description   text default '',
  assignee      text default '',
  due_date      date,
  priority      text not null default 'Medium' check (priority in ('Low','Medium','High','Urgent')),
  status        text not null default 'To Do' check (status in ('To Do','In Progress','Done')),
  sort_order    integer not null default 0,
  created_by    text default '',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now(),
  completed_at  timestamptz
);

create index if not exists tasks_status_idx on public.tasks (status, sort_order);

alter table public.tasks enable row level security;
drop policy if exists tasks_rw on public.tasks;
create policy tasks_rw on public.tasks for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'tasks'
  ) then
    alter publication supabase_realtime add table public.tasks;
  end if;
end $$;

-- ============================================================
-- COMPANY PPE REGISTER (property, plant & equipment acquired)
-- ============================================================

create table if not exists public.ppe_assets (
  id                uuid primary key default gen_random_uuid(),
  tag               text not null default '',
  name              text not null default '',
  category          text not null default 'IT Equipment',
  serial_no         text default '',
  date_acquired     date,
  cost              numeric not null default 0,
  supplier          text default '',
  location          text default '',
  custodian         text default '',
  status            text not null default 'In Use' check (status in ('In Use','In Storage','Under Maintenance','Disposed')),
  useful_life_years numeric default 0,
  disposed_date     date,
  disposed_value    numeric,
  notes             text default '',
  photo             text default '',
  created_by        text default '',
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

create index if not exists ppe_assets_status_idx on public.ppe_assets (status, created_at desc);

create table if not exists public.ppe_counters (
  counter_key text primary key,
  value       integer not null default 0
);

create or replace function public.next_ppe_tag()
returns text language plpgsql security definer as $$
declare v integer;
begin
  update public.ppe_counters set value = value + 1 where counter_key = 'global' returning value into v;
  if v is null then
    insert into public.ppe_counters(counter_key, value) values ('global', 1) returning value into v;
  end if;
  return 'KIRU-PPE-' || lpad(v::text, 4, '0');
end $$;

alter table public.ppe_assets    enable row level security;
alter table public.ppe_counters  enable row level security;
drop policy if exists ppe_assets_rw   on public.ppe_assets;
drop policy if exists ppe_counters_r  on public.ppe_counters;
create policy ppe_assets_rw   on public.ppe_assets    for all    to authenticated using (true) with check (true);
create policy ppe_counters_r  on public.ppe_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'ppe_assets'
  ) then
    alter publication supabase_realtime add table public.ppe_assets;
  end if;
end $$;

-- ============================================================
-- LIF INVENTORY
-- ============================================================

create table if not exists public.lif_items (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  sku         text default '',
  category    text default '',
  unit        text default 'Unit',
  qty         numeric default 0,
  cost        numeric default 0,
  reorder     numeric default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table if not exists public.lif_documents (
  id             uuid primary key default gen_random_uuid(),
  kind           text not null check (kind in ('po','mro')),
  no             text not null,
  doc_date       date not null default current_date,
  status         text not null default 'draft',
  supplier       text default '',
  requested_by   text default '',
  project        text default '',
  note           text default '',
  lines          jsonb not null default '[]'::jsonb,
  prepared_by    text default '',
  approved_by    text default '',
  approver_title text default '',
  signature      text default '',
  applied_date   date,
  payment_receipt text default '',
  purpose        text default '',
  created_by     text default '',
  created_at     timestamptz default now()
);

create table if not exists public.lif_counters (
  kind  text primary key,
  value integer not null default 0
);
insert into public.lif_counters (kind, value) values ('po',0), ('mro',0)
  on conflict (kind) do nothing;

create index if not exists lif_documents_kind_idx on public.lif_documents (kind, created_at desc);

create table if not exists public.lif_bos_packages (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text default '',
  components  jsonb not null default '[]'::jsonb,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.lif_bos_packages enable row level security;
drop policy if exists lif_bos_packages_rw on public.lif_bos_packages;
create policy lif_bos_packages_rw on public.lif_bos_packages for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_bos_packages'
  ) then
    alter publication supabase_realtime add table public.lif_bos_packages;
  end if;
end $$;

-- ============================================================
-- LIF DEPLOYMENT COSTS (Phase 1 capital cost register)
-- ============================================================

create table if not exists public.lif_deployment_costs (
  id          uuid primary key default gen_random_uuid(),
  ref         text not null default '',
  customer    text not null default '',
  location    text default '',
  site_date   date,
  cls         text not null default 'SGS' check (cls in ('SGS','GBS')),
  config      text not null default 'separate' check (config in ('separate','aio')),
  panels      jsonb not null default '{"q":0,"p":0,"cap":""}'::jsonb,
  inverter    jsonb not null default '{"q":0,"p":0,"cap":""}'::jsonb,
  battery     jsonb not null default '{"q":0,"p":0,"cap":""}'::jsonb,
  generator   jsonb not null default '{"q":0,"p":0,"cap":""}'::jsonb,
  bos         jsonb not null default '{"q":1,"p":0,"cap":""}'::jsonb,
  iot         jsonb not null default '{"q":1,"p":0,"cap":""}'::jsonb,
  period      text default '',
  sort_order  integer not null default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create index if not exists lif_deployment_costs_sort_idx on public.lif_deployment_costs (sort_order);

alter table public.lif_deployment_costs enable row level security;
drop policy if exists lif_deployment_costs_rw on public.lif_deployment_costs;
create policy lif_deployment_costs_rw on public.lif_deployment_costs for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_deployment_costs'
  ) then
    alter publication supabase_realtime add table public.lif_deployment_costs;
  end if;
end $$;

-- ============================================================
-- LIF PHASE 1 INSTALLATIONS (deployment / commissioning register)
-- ============================================================

create table if not exists public.lif_phase1_installations (
  id            uuid primary key default gen_random_uuid(),
  ref           text not null default '',
  business      text not null default '',
  category      text not null default 'SME' check (category in ('Residential','SME')),
  cluster       text default '',
  cls           text not null default 'SGS' check (cls in ('SGS','GBS')),
  pv_qty        numeric not null default 0,
  pv_w          numeric not null default 0,
  inv_kw        numeric not null default 0,
  bat_kwh       numeric not null default 0,
  comm_date     date,
  status        text not null default 'Commissioned',
  beneficiaries numeric not null default 0,
  media_link    text default '',
  iot_link      text default '',
  checks        jsonb not null default '[true,true,true,true,true]'::jsonb,
  period        text default '',
  sort_order    integer not null default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

create index if not exists lif_phase1_installations_sort_idx on public.lif_phase1_installations (sort_order);

alter table public.lif_phase1_installations enable row level security;
drop policy if exists lif_phase1_installations_rw on public.lif_phase1_installations;
create policy lif_phase1_installations_rw on public.lif_phase1_installations for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_phase1_installations'
  ) then
    alter publication supabase_realtime add table public.lif_phase1_installations;
  end if;
end $$;

-- ============================================================
-- LIF REPORT META (letterhead / top-level fields for the Phase 1
-- Deployment Report and Deployment Cost Manager tools)
-- ============================================================

create table if not exists public.lif_report_meta (
  report_key  text primary key,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz default now()
);

alter table public.lif_report_meta enable row level security;
drop policy if exists lif_report_meta_rw on public.lif_report_meta;
create policy lif_report_meta_rw on public.lif_report_meta for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_report_meta'
  ) then
    alter publication supabase_realtime add table public.lif_report_meta;
  end if;
end $$;

-- ============================================================
-- LIF TIME SHEET (work days logged per team member)
-- ============================================================

create table if not exists public.lif_timesheet_entries (
  id          uuid primary key default gen_random_uuid(),
  work_date   date not null default current_date,
  member_name text not null default '',
  role_title  text default '',
  department  text default '',
  site        text default '',
  day_rate    numeric not null default 0,
  days        numeric not null default 1,
  notes       text default '',
  created_by  text default '',
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create index if not exists lif_timesheet_entries_date_idx on public.lif_timesheet_entries (work_date desc);

alter table public.lif_timesheet_entries enable row level security;
drop policy if exists lif_timesheet_entries_rw on public.lif_timesheet_entries;
create policy lif_timesheet_entries_rw on public.lif_timesheet_entries for all to authenticated using (true) with check (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_timesheet_entries'
  ) then
    alter publication supabase_realtime add table public.lif_timesheet_entries;
  end if;
end $$;

-- ============================================================
-- LIF EXPENSE TRACKER (project expenses incurred)
-- ============================================================

create table if not exists public.lif_expenses (
  id             uuid primary key default gen_random_uuid(),
  ref            text not null default '',
  expense_date   date not null default current_date,
  category       text not null default 'Miscellaneous' check (category in ('Logistics','Marketing','Site Expenses','Fixed Assets','Utilities','Professional Fees','Miscellaneous')),
  description    text not null default '',
  amount         numeric not null default 0,
  site           text default '',
  vendor         text default '',
  payment_method text default '',
  receipt        text default '',
  notes          text default '',
  created_by     text default '',
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

create index if not exists lif_expenses_date_idx on public.lif_expenses (expense_date desc);

create table if not exists public.lif_expense_counters (
  counter_key text primary key,
  value       integer not null default 0
);

create or replace function public.next_expense_ref()
returns text language plpgsql security definer as $$
declare v integer;
begin
  update public.lif_expense_counters set value = value + 1 where counter_key = 'global' returning value into v;
  if v is null then
    insert into public.lif_expense_counters(counter_key, value) values ('global', 1) returning value into v;
  end if;
  return 'KIRU-EXP-' || lpad(v::text, 4, '0');
end $$;

alter table public.lif_expenses          enable row level security;
alter table public.lif_expense_counters  enable row level security;
drop policy if exists lif_expenses_rw         on public.lif_expenses;
drop policy if exists lif_expense_counters_r  on public.lif_expense_counters;
create policy lif_expenses_rw         on public.lif_expenses          for all    to authenticated using (true) with check (true);
create policy lif_expense_counters_r  on public.lif_expense_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_expenses'
  ) then
    alter publication supabase_realtime add table public.lif_expenses;
  end if;
end $$;

-- ============================================================
-- FUNCTIONS — COMPANY
-- ============================================================

create or replace function public.next_doc_no(p_kind text)
returns text language plpgsql security definer as $$
declare v integer; prefix text;
begin
  update public.counters set value = value + 1 where kind = p_kind returning value into v;
  if v is null then
    insert into public.counters(kind, value) values (p_kind, 1) returning value into v;
  end if;
  prefix := case when p_kind = 'po' then 'PO' else 'MRO' end;
  return 'KIRU-' || prefix || '-' || to_char(now(),'YYYYMM') || '-' || lpad(v::text, 3, '0');
end $$;

create or replace function public.apply_document(p_id uuid)
returns void language plpgsql security definer as $$
declare d record; ln jsonb; pkg record; comp jsonb;
begin
  select * into d from public.documents where id = p_id for update;
  if d is null then raise exception 'Document not found'; end if;
  if d.status <> 'draft' then raise exception 'Document already applied'; end if;
  for ln in select * from jsonb_array_elements(d.lines) loop
    if (ln ? 'packageId') and (ln->>'packageId') is not null then
      select * into pkg from public.bos_packages where id = (ln->>'packageId')::uuid;
      if pkg is not null then
        for comp in select * from jsonb_array_elements(pkg.components) loop
          update public.items
             set qty = coalesce(qty,0) + (case when d.kind = 'po' then 1 else -1 end)
                       * coalesce((comp->>'qty')::numeric,0) * coalesce((ln->>'qty')::numeric,0),
                 updated_at = now()
           where id = (comp->>'itemId')::uuid;
        end loop;
      end if;
    elsif d.kind = 'po' then
      update public.items
         set qty = coalesce(qty,0) + coalesce((ln->>'qty')::numeric,0),
             cost = case when coalesce((ln->>'cost')::numeric,0) > 0 then (ln->>'cost')::numeric else cost end,
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    else
      update public.items
         set qty = coalesce(qty,0) - coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    end if;
  end loop;
  update public.documents
     set status = case when d.kind = 'po' then 'received' else 'issued' end,
         applied_date = current_date
   where id = p_id;
end $$;

create or replace function public.unissue_document(p_id uuid)
returns void language plpgsql security definer as $$
declare d record; ln jsonb; pkg record; comp jsonb;
begin
  select * into d from public.documents where id = p_id for update;
  if d is null then raise exception 'Document not found'; end if;
  if d.status = 'draft' then raise exception 'Document is already a draft'; end if;
  for ln in select * from jsonb_array_elements(d.lines) loop
    if (ln ? 'packageId') and (ln->>'packageId') is not null then
      select * into pkg from public.bos_packages where id = (ln->>'packageId')::uuid;
      if pkg is not null then
        for comp in select * from jsonb_array_elements(pkg.components) loop
          update public.items
             set qty = coalesce(qty,0) + (case when d.kind = 'po' then -1 else 1 end)
                       * coalesce((comp->>'qty')::numeric,0) * coalesce((ln->>'qty')::numeric,0),
                 updated_at = now()
           where id = (comp->>'itemId')::uuid;
        end loop;
      end if;
    elsif d.kind = 'po' then
      update public.items
         set qty = coalesce(qty,0) - coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    else
      update public.items
         set qty = coalesce(qty,0) + coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    end if;
  end loop;
  update public.documents
     set status = 'draft', applied_date = null
   where id = p_id;
end $$;

-- ============================================================
-- FUNCTIONS — LIF
-- ============================================================

create or replace function public.lif_next_doc_no(p_kind text)
returns text language plpgsql security definer as $$
declare v integer; prefix text;
begin
  update public.lif_counters set value = value + 1 where kind = p_kind returning value into v;
  if v is null then
    insert into public.lif_counters(kind, value) values (p_kind, 1) returning value into v;
  end if;
  prefix := case when p_kind = 'po' then 'PO' else 'MRO' end;
  return 'LIF-' || prefix || '-' || to_char(now(),'YYYYMM') || '-' || lpad(v::text, 3, '0');
end $$;

create or replace function public.lif_apply_document(p_id uuid)
returns void language plpgsql security definer as $$
declare d record; ln jsonb; pkg record; comp jsonb;
begin
  select * into d from public.lif_documents where id = p_id for update;
  if d is null then raise exception 'Document not found'; end if;
  if d.status <> 'draft' then raise exception 'Document already applied'; end if;
  for ln in select * from jsonb_array_elements(d.lines) loop
    if (ln ? 'packageId') and (ln->>'packageId') is not null then
      select * into pkg from public.lif_bos_packages where id = (ln->>'packageId')::uuid;
      if pkg is not null then
        for comp in select * from jsonb_array_elements(pkg.components) loop
          update public.lif_items
             set qty = coalesce(qty,0) + (case when d.kind = 'po' then 1 else -1 end)
                       * coalesce((comp->>'qty')::numeric,0) * coalesce((ln->>'qty')::numeric,0),
                 updated_at = now()
           where id = (comp->>'itemId')::uuid;
        end loop;
      end if;
    elsif d.kind = 'po' then
      update public.lif_items
         set qty = coalesce(qty,0) + coalesce((ln->>'qty')::numeric,0),
             cost = case when coalesce((ln->>'cost')::numeric,0) > 0 then (ln->>'cost')::numeric else cost end,
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    else
      update public.lif_items
         set qty = coalesce(qty,0) - coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    end if;
  end loop;
  update public.lif_documents
     set status = case when d.kind = 'po' then 'received' else 'issued' end,
         applied_date = current_date
   where id = p_id;
end $$;

create or replace function public.lif_unissue_document(p_id uuid)
returns void language plpgsql security definer as $$
declare d record; ln jsonb; pkg record; comp jsonb;
begin
  select * into d from public.lif_documents where id = p_id for update;
  if d is null then raise exception 'Document not found'; end if;
  if d.status = 'draft' then raise exception 'Document is already a draft'; end if;
  for ln in select * from jsonb_array_elements(d.lines) loop
    if (ln ? 'packageId') and (ln->>'packageId') is not null then
      select * into pkg from public.lif_bos_packages where id = (ln->>'packageId')::uuid;
      if pkg is not null then
        for comp in select * from jsonb_array_elements(pkg.components) loop
          update public.lif_items
             set qty = coalesce(qty,0) + (case when d.kind = 'po' then -1 else 1 end)
                       * coalesce((comp->>'qty')::numeric,0) * coalesce((ln->>'qty')::numeric,0),
                 updated_at = now()
           where id = (comp->>'itemId')::uuid;
        end loop;
      end if;
    elsif d.kind = 'po' then
      update public.lif_items
         set qty = coalesce(qty,0) - coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    else
      update public.lif_items
         set qty = coalesce(qty,0) + coalesce((ln->>'qty')::numeric,0),
             updated_at = now()
       where id = (ln->>'itemId')::uuid;
    end if;
  end loop;
  update public.lif_documents
     set status = 'draft', applied_date = null
   where id = p_id;
end $$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.items          enable row level security;
alter table public.documents      enable row level security;
alter table public.counters       enable row level security;
alter table public.lif_items      enable row level security;
alter table public.lif_documents  enable row level security;
alter table public.lif_counters   enable row level security;

drop policy if exists items_rw          on public.items;
drop policy if exists documents_rw      on public.documents;
drop policy if exists counters_r        on public.counters;
drop policy if exists lif_items_rw      on public.lif_items;
drop policy if exists lif_documents_rw  on public.lif_documents;
drop policy if exists lif_counters_r    on public.lif_counters;

create policy items_rw          on public.items          for all to authenticated using (true) with check (true);
create policy documents_rw      on public.documents      for all to authenticated using (true) with check (true);
create policy counters_r        on public.counters        for select to authenticated using (true);
create policy lif_items_rw      on public.lif_items      for all to authenticated using (true) with check (true);
create policy lif_documents_rw  on public.lif_documents  for all to authenticated using (true) with check (true);
create policy lif_counters_r    on public.lif_counters    for select to authenticated using (true);

-- ============================================================
-- REALTIME
-- ============================================================

alter publication supabase_realtime add table public.items;
alter publication supabase_realtime add table public.documents;
alter publication supabase_realtime add table public.lif_items;
alter publication supabase_realtime add table public.lif_documents;
