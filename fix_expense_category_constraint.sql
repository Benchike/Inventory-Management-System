do $$
declare r record;
begin
  for r in (select conname from pg_constraint where conrelid = 'public.lif_expenses'::regclass and contype = 'c')
  loop
    raise notice 'dropping constraint: %', r.conname;
    execute format('alter table public.lif_expenses drop constraint %I', r.conname);
  end loop;
end $$;

alter table public.lif_expenses add constraint lif_expenses_category_check
  check (category in ('Operating / Digital Services','Installation / Site Labour','Logistics / Site Expense','Fixed Asset / Field Equipment','Fixed Asset / Communication','Bank / Operating Cost','Safety / Field Equipment','Vehicle / Operating Cost','Printing / Marketing'));

select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'public.lif_expenses'::regclass and contype = 'c';
