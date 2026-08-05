-- ============================================================
-- Kiru Energy — Inventory Management System
-- Supabase schema.  Run once in Supabase → SQL Editor → New query.
-- ============================================================

-- ---------- TABLES ----------
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
  status         text not null default 'draft',      -- draft | received | issued
  supplier       text default '',
  requested_by   text default '',
  project        text default '',
  note           text default '',
  lines          jsonb not null default '[]'::jsonb, -- [{itemId, qty, cost}]
  prepared_by    text default '',
  approved_by    text default '',
  approver_title text default '',
  signature      text default '',                    -- data URL
  applied_date      date,                               -- received / issued date
  payment_receipt   text default '',                    -- data URL of uploaded payment receipt (PO only)
  created_by        text default '',
  created_at        timestamptz default now()
);

-- Add payment_receipt to existing deployments (safe to re-run)
alter table public.documents add column if not exists payment_receipt text default '';

create table if not exists public.counters (
  kind  text primary key,
  value integer not null default 0
);
insert into public.counters (kind, value) values ('po',0), ('mro',0)
  on conflict (kind) do nothing;

create index if not exists documents_kind_idx on public.documents (kind, created_at desc);

-- ---------- DOCUMENT NUMBERING (atomic) ----------
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

-- ---------- APPLY A DOCUMENT TO STOCK (atomic) ----------
-- Receiving a PO adds stock; issuing an MRO removes it.
create or replace function public.apply_document(p_id uuid)
returns void language plpgsql security definer as $$
declare d record; ln jsonb;
begin
  select * into d from public.documents where id = p_id for update;
  if d is null then raise exception 'Document not found'; end if;
  if d.status <> 'draft' then raise exception 'Document already applied'; end if;

  for ln in select * from jsonb_array_elements(d.lines) loop
    if d.kind = 'po' then
      update public.items
         set qty = coalesce(qty,0) + coalesce((ln->>'qty')::numeric,0),
             cost = case when coalesce((ln->>'cost')::numeric,0) > 0
                         then (ln->>'cost')::numeric else cost end,
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

-- ---------- ROW LEVEL SECURITY ----------
-- Any signed-in team member may read and write. Anonymous visitors get nothing.
alter table public.items      enable row level security;
alter table public.documents  enable row level security;
alter table public.counters   enable row level security;

drop policy if exists items_rw      on public.items;
drop policy if exists documents_rw  on public.documents;
drop policy if exists counters_r    on public.counters;

create policy items_rw     on public.items     for all to authenticated using (true) with check (true);
create policy documents_rw on public.documents for all to authenticated using (true) with check (true);
create policy counters_r   on public.counters  for select to authenticated using (true);

-- ---------- REALTIME ----------
alter publication supabase_realtime add table public.items;
alter publication supabase_realtime add table public.documents;
