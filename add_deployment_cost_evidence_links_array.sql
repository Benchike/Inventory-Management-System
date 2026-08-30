alter table public.lif_deployment_costs add column if not exists evidence_links jsonb not null default '[]'::jsonb;
