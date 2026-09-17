-- ============================================================
-- PROJECT SITE EXPENSES — ADD "LOGISTICS" CATEGORY
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

do $$
declare r record;
begin
  for r in (select conname from pg_constraint where conrelid = 'public.project_site_expenses'::regclass and contype = 'c')
  loop
    execute format('alter table public.project_site_expenses drop constraint %I', r.conname);
  end loop;
end $$;

alter table public.project_site_expenses add constraint project_site_expenses_category_check
  check (category in ('Equipment','Logistics','Installer Labour','Miscellaneous'));
