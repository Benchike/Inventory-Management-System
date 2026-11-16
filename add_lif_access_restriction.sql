-- ============================================================
-- LIF PROJECT MANAGER — RESTRICT ACCESS TO THE LIF TEAM
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
--
-- Only the emails listed in is_lif_member() can read or change any
-- lif_* table. Everyone else gets nothing back from those tables.
-- To add or remove someone: edit the list below, re-run this file,
-- and make the same change in lif-access.js.
-- ============================================================

create or replace function public.is_lif_member()
returns boolean language sql stable as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'benokpala@ourkiru.com',
    'cole@ourkiru.com'
  );
$$;

do $$
declare t record; p record;
begin
  for t in
    select tablename from pg_tables
    where schemaname = 'public' and tablename like 'lif\_%'
  loop
    -- remove every existing policy on the table (the old ones let any signed-in user in)
    for p in
      select policyname from pg_policies
      where schemaname = 'public' and tablename = t.tablename
    loop
      execute format('drop policy %I on public.%I', p.policyname, t.tablename);
    end loop;

    execute format('alter table public.%I enable row level security', t.tablename);

    if t.tablename like '%counters' then
      -- counters are only ever read directly; numbering functions do the writing
      execute format(
        'create policy %I on public.%I for select to authenticated using (public.is_lif_member())',
        t.tablename || '_r', t.tablename);
    else
      execute format(
        'create policy %I on public.%I for all to authenticated using (public.is_lif_member()) with check (public.is_lif_member())',
        t.tablename || '_rw', t.tablename);
    end if;
  end loop;
end $$;

-- Check the result: every lif_ table should show is_lif_member() in both columns.
select tablename, policyname, cmd, qual, with_check
from pg_policies
where schemaname = 'public' and tablename like 'lif\_%'
order by tablename;
