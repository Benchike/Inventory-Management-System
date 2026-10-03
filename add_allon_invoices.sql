-- ============================================================
-- ALL ON GRANT INVOICES (Kiru Workspace)
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

create table if not exists public.allon_invoices (
  id               uuid primary key default gen_random_uuid(),
  inv_no           text not null unique,
  inv_date         date not null default current_date,
  currency         text not null default 'USD',
  grant_ref        text default '',
  attn             text default 'Finance Manager',
  bill_org         text default 'All On Partnerships for Energy Access Ltd/Gte',
  bill_addr        text default '',
  line_items       jsonb not null default '[]'::jsonb,
  total_amt        numeric not null default 0,
  corr_name        text default '',
  corr_addr        text default '',
  corr_swift       text default '',
  corr_iban        text default '',
  ben_bank_name    text default '',
  ben_sort_code    text default '',
  ben_account      text default '',
  ben_swift        text default '',
  fin_account_name text default 'Kiru Energy Ltd',
  fin_account_no   text default '',
  fin_bank_name    text default '',
  fin_address      text default '',
  ngn_account_name text default 'Kiru Energy Ltd',
  ngn_account_no   text default '',
  ngn_bank_name    text default '',
  notes            text default '',
  sign_name        text default 'Benedict Okpala',
  sign_title       text default 'Managing Director',
  signature        text default '',
  status           text not null default 'draft' check (status in ('draft','issued')),
  issued_at        timestamptz,
  created_by       text default '',
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create index if not exists allon_invoices_created_idx on public.allon_invoices (created_at desc);

create table if not exists public.allon_invoice_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_allon_invoice_no()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.allon_invoice_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.allon_invoice_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-ALLON-' || dkey || '-' || lpad(v::text, 4, '0');
end $$;

alter table public.allon_invoices          enable row level security;
alter table public.allon_invoice_counters  enable row level security;
drop policy if exists allon_invoices_rw          on public.allon_invoices;
drop policy if exists allon_invoice_counters_r   on public.allon_invoice_counters;
create policy allon_invoices_rw          on public.allon_invoices          for all    to authenticated using (true) with check (true);
create policy allon_invoice_counters_r   on public.allon_invoice_counters  for select to authenticated using (true);
