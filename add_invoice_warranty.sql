-- ============================================================
-- INVOICE GENERATOR — WARRANTY COLUMN FOR MAJOR COMPONENTS
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- (BOS accessories / other items use a fixed 12 months, so need no column.)
-- ============================================================

-- Component warranties shown on the invoice (years, or free text such as '10 years')
alter table public.invoices add column if not exists panel_warranty text default '';
alter table public.invoices add column if not exists inv_warranty   text default '';
alter table public.invoices add column if not exists batt_warranty  text default '';
