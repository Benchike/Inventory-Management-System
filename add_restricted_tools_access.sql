-- ============================================================
-- ALL ON GRANT INVOICE + SALES TARGET CALCULATOR — RESTRICT ACCESS
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
--
-- Only the emails listed in is_lif_member() can read or change the
-- All On grant invoices and the sales targets. This is the same list
-- that guards the LIF tables (add_lif_access_restriction.sql).
-- To add or remove someone: edit the list in BOTH sql files, re-run
-- them, and make the same change in lif-access.js.
-- ============================================================

create or replace function public.is_lif_member()
returns boolean language sql stable as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'benokpala@ourkiru.com',
    'cole@ourkiru.com'
  );
$$;

do $$
declare t text; p record;
begin
  foreach t in array array['allon_invoices', 'allon_invoice_counters', 'sales_targets']
  loop
    if to_regclass('public.' || t) is null then
      raise notice 'table public.% does not exist yet — skipped', t;
      continue;
    end if;

    -- remove every existing policy on the table (the old ones let any signed-in user in)
    for p in
      select policyname from pg_policies
      where schemaname = 'public' and tablename = t
    loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;

    execute format('alter table public.%I enable row level security', t);

    if t like '%counters' then
      -- counters are only ever read directly; the numbering function does the writing
      execute format(
        'create policy %I on public.%I for select to authenticated using (public.is_lif_member())',
        t || '_r', t);
    else
      execute format(
        'create policy %I on public.%I for all to authenticated using (public.is_lif_member()) with check (public.is_lif_member())',
        t || '_rw', t);
    end if;
  end loop;
end $$;

-- Check the result: each table should show is_lif_member() in the rule columns.
select tablename, policyname, cmd, qual, with_check
from pg_policies
where schemaname = 'public' and tablename in ('allon_invoices', 'allon_invoice_counters', 'sales_targets')
order by tablename;
