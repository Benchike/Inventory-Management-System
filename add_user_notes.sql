-- ============================================================
-- NOTES & REMINDERS — private notes with an optional reminder time
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
--
-- Every user only ever sees their own notes (row-level security on user_id).
-- ============================================================

create table if not exists public.user_notes (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title       text not null default '',
  body        text not null default '',
  remind_at   timestamptz,
  reminded    boolean not null default false,   -- true once the reminder alert has been shown
  done        boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists user_notes_user_idx on public.user_notes (user_id, remind_at);

alter table public.user_notes enable row level security;
drop policy if exists user_notes_own on public.user_notes;
create policy user_notes_own on public.user_notes
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
