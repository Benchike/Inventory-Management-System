create table if not exists public.site_assessments (
  id                uuid primary key default gen_random_uuid(),
  ref_no            text not null unique,
  assess_date       date not null default current_date,
  assessor          text default '',
  cust_name         text default '',
  cust_phone        text default '',
  cust_email        text default '',
  cust_addr         text default '',
  purpose           text default 'Home Use',
  supply_interval   text default '',
  building          text default 'Bungalow',
  floor             text default 'Ground Floor',
  apartment         text default 'Self contain',
  grid_band         text default '',
  grid_config       text default 'Single-phase',
  grid_hours        numeric default 0,
  periods           jsonb not null default '[]'::jsonb,
  offgrid           text default 'No',
  remote_mon        text default 'No',
  meter_type        text default 'Prepaid',
  grid_voltage      text default '',
  alt_type          text default 'None',
  alt_cap           text default '',
  loads             jsonb not null default '[]'::jsonb,
  photos            jsonb not null default '{}'::jsonb,
  notes             text default '',
  daily_kwh         numeric not null default 0,
  created_by        text default '',
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

create index if not exists site_assessments_created_idx on public.site_assessments (created_at desc);

create table if not exists public.site_assessment_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_site_assessment_ref()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.site_assessment_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.site_assessment_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-SA-' || dkey || '-' || lpad(v::text, 3, '0');
end $$;

alter table public.site_assessments          enable row level security;
alter table public.site_assessment_counters  enable row level security;
drop policy if exists site_assessments_rw          on public.site_assessments;
drop policy if exists site_assessment_counters_r   on public.site_assessment_counters;
create policy site_assessments_rw          on public.site_assessments          for all    to authenticated using (true) with check (true);
create policy site_assessment_counters_r   on public.site_assessment_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'site_assessments'
  ) then
    alter publication supabase_realtime add table public.site_assessments;
  end if;
end $$;
