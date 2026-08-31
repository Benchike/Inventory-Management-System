alter table public.lif_deployment_costs add column if not exists media_links jsonb not null default '[]'::jsonb;
