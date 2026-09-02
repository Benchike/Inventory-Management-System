create table if not exists public.project_sites (
  id                    uuid primary key default gen_random_uuid(),
  site_no               text not null unique,
  shop_location         text default '',
  state_region          text default '',
  contact_person        text default '',
  phone_number          text default '',
  lease_term            text default '',
  stage                 text not null default 'Site Survey' check (stage in ('Site Survey','Installation In Progress','Installation Complete','Commissioned','Active – In Service')),
  survey_date           date,
  install_start_date    date,
  install_complete_date date,
  commissioning_date    date,
  pre_install_photos    jsonb not null default '[]'::jsonb,
  post_install_photos   jsonb not null default '[]'::jsonb,
  notes                 text default '',
  created_by            text default '',
  created_at            timestamptz default now(),
  updated_at            timestamptz default now()
);

create index if not exists project_sites_stage_idx on public.project_sites (stage);

create table if not exists public.project_site_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_project_site_no()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.project_site_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.project_site_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-SITE-' || dkey || '-' || lpad(v::text, 3, '0');
end $$;

create table if not exists public.project_site_complaints (
  id               uuid primary key default gen_random_uuid(),
  site_id          uuid not null references public.project_sites(id) on delete cascade,
  date_reported    date not null default current_date,
  description      text not null default '',
  status           text not null default 'Open' check (status in ('Open','In Progress','Resolved')),
  resolution_notes text default '',
  created_by       text default '',
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);
create index if not exists project_site_complaints_site_idx on public.project_site_complaints (site_id, date_reported desc);

create table if not exists public.project_site_maintenance (
  id             uuid primary key default gen_random_uuid(),
  site_id        uuid not null references public.project_sites(id) on delete cascade,
  visit_date     date not null default current_date,
  visit_type     text not null default 'Routine' check (visit_type in ('Routine','Corrective','Preventive','Inspection')),
  technician     text default '',
  notes          text default '',
  next_visit_due date,
  created_by     text default '',
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);
create index if not exists project_site_maintenance_site_idx on public.project_site_maintenance (site_id, visit_date desc);

alter table public.project_sites             enable row level security;
alter table public.project_site_counters     enable row level security;
alter table public.project_site_complaints   enable row level security;
alter table public.project_site_maintenance  enable row level security;
drop policy if exists project_sites_rw             on public.project_sites;
drop policy if exists project_site_counters_r       on public.project_site_counters;
drop policy if exists project_site_complaints_rw    on public.project_site_complaints;
drop policy if exists project_site_maintenance_rw   on public.project_site_maintenance;
create policy project_sites_rw             on public.project_sites             for all    to authenticated using (true) with check (true);
create policy project_site_counters_r      on public.project_site_counters     for select to authenticated using (true);
create policy project_site_complaints_rw   on public.project_site_complaints   for all    to authenticated using (true) with check (true);
create policy project_site_maintenance_rw  on public.project_site_maintenance  for all    to authenticated using (true) with check (true);

do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='project_sites') then
    alter publication supabase_realtime add table public.project_sites;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='project_site_complaints') then
    alter publication supabase_realtime add table public.project_site_complaints;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='project_site_maintenance') then
    alter publication supabase_realtime add table public.project_site_maintenance;
  end if;
end $$;
