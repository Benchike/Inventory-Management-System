-- Imperium Invoice template: extra fields on the invoices table.
-- Existing invoices are unaffected; they default to the standard template.
alter table public.invoices add column if not exists template text    default 'standard';
alter table public.invoices add column if not exists audit    jsonb   not null default '[]'::jsonb;
alter table public.invoices add column if not exists diagram  text    default '';
alter table public.invoices add column if not exists terms    text    default '';
