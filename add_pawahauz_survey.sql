-- ============================================================
-- PAWAHAUZ ENERGY SURVEY — sites, resident surveys, ref numbers
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

create table if not exists public.pawahauz_sites (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  address      text default '',
  total_units  integer not null default 0,
  assumptions  jsonb not null default '{}'::jsonb,
  created_by   text default '',
  created_at   timestamptz default now()
);

create table if not exists public.pawahauz_surveys (
  id             uuid primary key default gen_random_uuid(),
  site_id        uuid not null references public.pawahauz_sites(id) on delete cascade,
  ref_no         text not null unique,
  survey_date    date not null default current_date,
  surveyor       text default '',
  resident_name  text default '',
  phone          text default '',
  email          text default '',
  unit_no        text default '',
  floor          text default '',
  apt_type       text default '',
  occupants      integer not null default 0,
  occupancy      text default '',
  grid_band      text default '',
  grid_hours     numeric not null default 0,
  grid_spend     numeric not null default 0,
  backup_type    text default 'None',
  backup_size    text default '',
  fuel_spend     numeric not null default 0,
  gen_hours      numeric not null default 0,
  interest       text default 'Very interested',
  pay_pref       text default '',
  max_spend      numeric not null default 0,
  supply_hours   text default '',
  appliances     jsonb not null default '[]'::jsonb,
  notes          text default '',
  daily_kwh      numeric not null default 0,
  peak_w         numeric not null default 0,
  created_by     text default '',
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

create index if not exists pawahauz_surveys_site_idx on public.pawahauz_surveys (site_id, created_at);

create table if not exists public.pawahauz_survey_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_pawahauz_survey_ref()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.pawahauz_survey_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.pawahauz_survey_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'PH-SV-' || dkey || '-' || lpad(v::text, 3, '0');
end $$;

alter table public.pawahauz_sites            enable row level security;
alter table public.pawahauz_surveys          enable row level security;
alter table public.pawahauz_survey_counters  enable row level security;
drop policy if exists pawahauz_sites_rw            on public.pawahauz_sites;
drop policy if exists pawahauz_surveys_rw          on public.pawahauz_surveys;
drop policy if exists pawahauz_survey_counters_r   on public.pawahauz_survey_counters;
create policy pawahauz_sites_rw            on public.pawahauz_sites            for all    to authenticated using (true) with check (true);
create policy pawahauz_surveys_rw          on public.pawahauz_surveys          for all    to authenticated using (true) with check (true);
create policy pawahauz_survey_counters_r   on public.pawahauz_survey_counters  for select to authenticated using (true);
