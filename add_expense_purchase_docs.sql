alter table public.lif_expenses add column if not exists purchase_docs jsonb not null default '[]'::jsonb;
