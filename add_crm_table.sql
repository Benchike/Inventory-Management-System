create table if not exists public.crm_leads (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  phone             text default '',
  email             text default '',
  address           text default '',
  customer_type     text default 'Home',
  source            text default 'WhatsApp',
  stage             text not null default 'new',
  est_value         numeric not null default 0,
  system_need       text default '',
  owner             text default '',
  next_followup     date,
  next_action       text default '',
  invoice_no        text default '',
  lost_reason       text default '',
  activities        jsonb not null default '[]'::jsonb,
  stage_changed_at  timestamptz default now(),
  last_contact_at   timestamptz,
  deal_at           timestamptz,
  created_by        text default '',
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

alter table public.crm_leads drop constraint if exists crm_leads_stage_check;
alter table public.crm_leads add constraint crm_leads_stage_check
  check (stage in ('new','site_visit','quote','deal','install','lost'));

create index if not exists crm_leads_stage_idx    on public.crm_leads (stage);
create index if not exists crm_leads_followup_idx on public.crm_leads (next_followup);
create index if not exists crm_leads_updated_idx  on public.crm_leads (updated_at desc);

alter table public.crm_leads enable row level security;
drop policy if exists crm_leads_rw on public.crm_leads;
create policy crm_leads_rw on public.crm_leads for all to authenticated using (true) with check (true);

-- live updates between team members
do $$
begin
  alter publication supabase_realtime add table public.crm_leads;
exception when duplicate_object then null;
end $$;
