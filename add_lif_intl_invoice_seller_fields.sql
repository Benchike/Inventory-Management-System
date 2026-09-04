alter table public.lif_intl_invoices add column if not exists doc_title      text not null default 'INVOICE';
alter table public.lif_intl_invoices add column if not exists company_name   text default 'Kiru Energy Ltd';
alter table public.lif_intl_invoices add column if not exists company_reg    text default 'RC 1619891';
alter table public.lif_intl_invoices add column if not exists company_addr  text default '44 Bourdillon Road, Ikoyi, Lagos, Nigeria';
alter table public.lif_intl_invoices add column if not exists company_email text default 'Business@ourkiru.com';
alter table public.lif_intl_invoices add column if not exists company_phone text default '+234-813-026-6232';
alter table public.lif_intl_invoices add column if not exists footer_note   text default 'Kiru Energy Ltd is registered in Nigeria (RC 1619891) · www.ourkiru.com';
