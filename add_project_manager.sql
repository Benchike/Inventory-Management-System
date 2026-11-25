-- ============================================================
-- PROJECT MANAGER (formerly Project Site Manager)
--  1) "System use case" on every project: Business / Home / Both
--  2) Equipment lines can be picked from the company inventory; the quantity used is
--     taken off the inventory stock automatically (and given back if the line is
--     changed, unlinked or deleted).
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- ============================================================

-- 1) System use case
alter table public.project_sites
  add column if not exists system_use_case text not null default '' check (system_use_case in ('', 'Business', 'Home', 'Both'));

-- 2) Link expense lines to inventory items
alter table public.project_site_expenses add column if not exists item_id uuid references public.items(id) on delete set null;
alter table public.project_site_expenses add column if not exists inv_qty numeric not null default 0;   -- quantity currently taken from stock for this line
create index if not exists project_site_expenses_item_idx on public.project_site_expenses (item_id);

-- Sets what this expense line takes from stock, in one step:
--   gives back whatever the line took before, then takes p_qty of p_item (p_item null = nothing).
--   Refuses (and changes nothing) if there is not enough stock. Returns the stock left.
create or replace function public.apply_project_expense_stock(p_expense uuid, p_item uuid, p_qty numeric)
returns numeric language plpgsql security definer set search_path = public as $$
declare e record; avail numeric; left_qty numeric := null;
begin
  select * into e from public.project_site_expenses where id = p_expense for update;
  if not found then raise exception 'Expense line not found'; end if;

  if e.item_id is not null and coalesce(e.inv_qty, 0) > 0 then
    update public.items set qty = qty + e.inv_qty, updated_at = now() where id = e.item_id;
  end if;

  if p_item is not null and coalesce(p_qty, 0) > 0 then
    select qty into avail from public.items where id = p_item for update;
    if not found then raise exception 'Inventory item not found'; end if;
    if coalesce(avail, 0) < p_qty then
      raise exception 'Not enough stock: only % in stock', coalesce(avail, 0);   -- rolls back the give-back above too
    end if;
    update public.items set qty = qty - p_qty, updated_at = now() where id = p_item returning qty into left_qty;
    update public.project_site_expenses set item_id = p_item, inv_qty = p_qty where id = p_expense;
  else
    update public.project_site_expenses set item_id = p_item, inv_qty = 0 where id = p_expense;
    if p_item is not null then select qty into left_qty from public.items where id = p_item; end if;
  end if;
  return left_qty;
end $$;
grant execute on function public.apply_project_expense_stock(uuid, uuid, numeric) to authenticated;

-- Deleting an expense line (or its whole project) gives the stock back.
create or replace function public.release_project_expense_stock() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.item_id is not null and coalesce(old.inv_qty, 0) > 0 then
    update public.items set qty = qty + old.inv_qty, updated_at = now() where id = old.item_id;
  end if;
  return old;
end $$;

drop trigger if exists trg_release_project_expense_stock on public.project_site_expenses;
create trigger trg_release_project_expense_stock
  before delete on public.project_site_expenses
  for each row execute function public.release_project_expense_stock();
