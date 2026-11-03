-- Default sign-off for NEW invoices: Benedict Okpala, CEO.
-- Receipts already default to Benedict Okpala, so only the invoices table changes.
-- Existing invoices keep the signer name saved on them.
alter table public.invoices alter column sign_name  set default 'Benedict Okpala';
alter table public.invoices alter column sign_title set default 'CEO';

-- OPTIONAL: also switch existing DRAFT invoices still signed by Chidi (issued ones are final, so they are left alone).
-- Uncomment to run:
-- update public.invoices set sign_name='Benedict Okpala', sign_title='CEO'
--  where status='draft' and sign_name='Chidi Okoronkwo';
