create table if not exists public.receipts (
  id              uuid primary key default gen_random_uuid(),
  rc_no           text not null unique,
  rc_date         date not null default current_date,
  client_name     text default '',
  client_addr     text default '',
  items           jsonb not null default '[]'::jsonb,
  total_amt       numeric not null default 0,
  pay_method      text default 'Bank Transfer',
  pay_ref         text default '',
  amount_paid     numeric not null default 0,
  bank_name       text default 'Wema Bank',
  account_name    text default 'Kiru Energy Ltd',
  account_number  text default '127429081',
  created_by      text default '',
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

create index if not exists receipts_created_idx on public.receipts (created_at desc);

create table if not exists public.receipt_counters (
  day_key text primary key,
  value   integer not null default 0
);

create or replace function public.next_receipt_no()
returns text language plpgsql security definer as $$
declare v integer; dkey text;
begin
  dkey := to_char(now(),'YYYYMMDD');
  update public.receipt_counters set value = value + 1 where day_key = dkey returning value into v;
  if v is null then
    insert into public.receipt_counters(day_key, value) values (dkey, 1) returning value into v;
  end if;
  return 'KIRU-RCT-' || dkey || '-' || lpad(v::text, 4, '0');
end $$;

alter table public.receipts          enable row level security;
alter table public.receipt_counters  enable row level security;
drop policy if exists receipts_rw          on public.receipts;
drop policy if exists receipt_counters_r   on public.receipt_counters;
create policy receipts_rw          on public.receipts          for all    to authenticated using (true) with check (true);
create policy receipt_counters_r   on public.receipt_counters  for select to authenticated using (true);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'receipts'
  ) then
    alter publication supabase_realtime add table public.receipts;
  end if;
end $$;
