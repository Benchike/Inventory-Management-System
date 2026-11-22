-- ============================================================
-- TASK MANAGEMENT — own tasks + assigning tasks to other users
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
--
-- Who can assign tasks to others: team_members.can_assign = true
--   (set below for Ben Okpala, Abayomi Cole and Joseph Alleh).
-- Everyone else can create and manage their own tasks, and update the status
-- of tasks assigned to them.
-- ============================================================

-- 1) Team directory (so people can be picked from a list). Filled from auth.users.
create table if not exists public.team_members (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  email      text not null,
  full_name  text not null default '',
  can_assign boolean not null default false
);

alter table public.team_members enable row level security;
drop policy if exists team_members_read on public.team_members;
create policy team_members_read on public.team_members for select to authenticated using (true);
-- no insert/update/delete policies: only the trigger below (and the SQL editor) can change it,
-- so nobody can grant themselves the right to assign.

create or replace function public.sync_team_member() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.team_members (user_id, email, full_name, can_assign)
  values (
    new.id, coalesce(new.email, ''),
    coalesce(nullif(trim(coalesce(new.raw_user_meta_data->>'first_name','') || ' ' || coalesce(new.raw_user_meta_data->>'last_name','')), ''),
             new.raw_user_meta_data->>'full_name', ''),
    lower(coalesce(new.email,'')) in ('benokpala@ourkiru.com','cole@ourkiru.com','joseph.alleh@ourkiru.com')
  )
  on conflict (user_id) do update
    set email = excluded.email,
        full_name = case when excluded.full_name <> '' then excluded.full_name else public.team_members.full_name end;
  return new;
end $$;

drop trigger if exists trg_sync_team_member on auth.users;
create trigger trg_sync_team_member
  after insert or update of email, raw_user_meta_data on auth.users
  for each row execute function public.sync_team_member();

-- back-fill existing accounts
insert into public.team_members (user_id, email, full_name)
select u.id, coalesce(u.email, ''),
       coalesce(nullif(trim(coalesce(u.raw_user_meta_data->>'first_name','') || ' ' || coalesce(u.raw_user_meta_data->>'last_name','')), ''),
                u.raw_user_meta_data->>'full_name', '')
from auth.users u
on conflict (user_id) do update
  set email = excluded.email,
      full_name = case when excluded.full_name <> '' then excluded.full_name else public.team_members.full_name end;

-- 2) People who can assign tasks to others
update public.team_members set can_assign = true
where lower(email) in ('benokpala@ourkiru.com', 'cole@ourkiru.com');

-- Joseph Alleh
update public.team_members set can_assign = true where lower(email) = 'joseph.alleh@ourkiru.com';

create or replace function public.can_assign_tasks() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select can_assign from public.team_members where user_id = auth.uid()), false)
$$;
grant execute on function public.can_assign_tasks() to authenticated;

-- 3) Tasks: who made it and who it is for
alter table public.tasks add column if not exists assignee_id   uuid references auth.users(id) on delete set null;
alter table public.tasks add column if not exists created_by_id uuid default auth.uid() references auth.users(id) on delete set null;
create index if not exists tasks_assignee_idx on public.tasks (assignee_id);
create index if not exists tasks_creator_idx  on public.tasks (created_by_id);

-- Existing tasks have no owner: they stay visible to everyone, as before.
alter table public.tasks enable row level security;
do $$ declare p record; begin
  for p in select policyname from pg_policies where schemaname='public' and tablename='tasks' loop
    execute format('drop policy %I on public.tasks', p.policyname);
  end loop;
end $$;

-- see: your own, ones assigned to you, everything if you are an assigner, and old ownerless ones
create policy tasks_select on public.tasks for select to authenticated using (
  created_by_id = auth.uid() or assignee_id = auth.uid() or public.can_assign_tasks()
  or (created_by_id is null and assignee_id is null)
);
-- create: as yourself; only assigners can give a task to someone else
create policy tasks_insert on public.tasks for insert to authenticated with check (
  created_by_id = auth.uid()
  and (assignee_id is null or assignee_id = auth.uid() or public.can_assign_tasks())
);
-- change: the creator, the assignee, an assigner, or old ownerless tasks
create policy tasks_update on public.tasks for update to authenticated using (
  created_by_id = auth.uid() or assignee_id = auth.uid() or public.can_assign_tasks()
  or (created_by_id is null and assignee_id is null)
) with check (
  assignee_id is null or assignee_id = auth.uid() or public.can_assign_tasks()
  or created_by_id is null
);
-- delete: the creator, an assigner, or old ownerless tasks
create policy tasks_delete on public.tasks for delete to authenticated using (
  created_by_id = auth.uid() or public.can_assign_tasks()
  or (created_by_id is null and assignee_id is null)
);

-- Check: these people can assign tasks
select full_name, email, can_assign from public.team_members order by can_assign desc, full_name;
