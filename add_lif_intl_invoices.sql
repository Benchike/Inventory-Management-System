create table if not exists public.lif_intl_invoices (
  id               uuid primary key default gen_random_uuid(),
  inv_no           text not null unique,
  inv_date         date not null default current_date,
  due_date         date,
  currency         text not null default 'GBP',
  payment_terms    text default 'Due upon receipt',
  doc_title        text not null default 'INVOICE',
  company_name     text default 'Kiru Energy Ltd',
  company_reg      text default 'RC 1619891',
  company_addr     text default '44 Bourdillon Road, Ikoyi, Lagos, Nigeria',
  company_email    text default 'Business@ourkiru.com',
  company_phone    text default '+234-813-026-6232',
  supplier_id      text default '',
  po_number        text default '',
  tax_id           text default '',
  bill_name        text default '',
  bill_org         text default '',
  bill_addr        text default '',
  line_items       jsonb not null default '[]'::jsonb,
  total_amt        numeric not null default 0,
  beneficiary_name text default 'Kiru Energy Ltd',
  beneficiary_addr text default '',
  bank_name        text default '',
  bank_addr        text default '',
  account_number   text default '',
  iban             text default '',
  swift_bic        text default '',
  sort_code        text default '',
  routing_number   text default '',
  use_intermediary boolean not null default false,
  int_bank_name    text default '',
  int_swift        text default '',
  int_account      text default '',
  ref_note         text default 'Please quote invoice number {invoiceNo} and PO number {poNumber} as payment reference. Unless otherwise agreed, bank charges outside Nigeria are payable by the remitter.',
  notes            text default '',
  footer_note      text default 'Kiru Energy Ltd is registered in Nigeria (RC 1619891) · www.ourkiru.com',
  sign_name        text default 'Benedict Okpala',
  sign_title       text default 'Director',
  signature        text default '',
  status           text not null default 'draft' check (status in ('draft','issued')),
  issued_at        timestamptz,
  created_by       text default '',
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create index if not exists lif_intl_invoices_status_idx on public.lif_intl_invoices (status, created_at desc);

create table if not exists public.lif_intl_invoice_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_intl_invoice_no()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.lif_intl_invoice_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.lif_intl_invoice_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-INTL-' || dkey || '-' || lpad(v::text, 4, '0');
end $$;

alter table public.lif_intl_invoices          enable row level security;
alter table public.lif_intl_invoice_counters  enable row level security;
drop policy if exists lif_intl_invoices_rw          on public.lif_intl_invoices;
drop policy if exists lif_intl_invoice_counters_r   on public.lif_intl_invoice_counters;
create policy lif_intl_invoices_rw          on public.lif_intl_invoices          for all    to authenticated using (true) with check (true);
create policy lif_intl_invoice_counters_r   on public.lif_intl_invoice_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lif_intl_invoices'
  ) then
    alter publication supabase_realtime add table public.lif_intl_invoices;
  end if;
end $$;
