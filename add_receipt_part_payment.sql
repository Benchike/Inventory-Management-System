-- ============================================================
-- RECEIPT GENERATOR — PART PAYMENT / PAYMENT PLAN AGREEMENT
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

alter table public.receipts add column if not exists receipt_type text not null default 'full';
do $$
begin
  if not exists (
    select 1 from pg_constraint where conrelid = 'public.receipts'::regclass and conname = 'receipts_type_check'
  ) then
    alter table public.receipts add constraint receipts_type_check check (receipt_type in ('full','part'));
  end if;
end $$;

alter table public.receipts add column if not exists balance_due_date    date;
alter table public.receipts add column if not exists balance_due_date_to date;
alter table public.receipts add column if not exists payment_terms       text default '';
