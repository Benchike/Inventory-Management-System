-- ============================================================
-- PAWAHAUZ — PUBLIC FIELD SURVEY LINK
-- Lets someone without a Kiru account (e.g. the site engineer) submit
-- surveys for one site through a secret link (?code=...).
-- They can submit and edit only the surveys they submitted; the tables
-- themselves stay closed to anyone who is not signed in.
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- Requires add_pawahauz_survey.sql to have been run first.
-- ============================================================

alter table public.pawahauz_sites add column if not exists access_code text;
update public.pawahauz_sites set access_code = upper(substr(md5(gen_random_uuid()::text), 1, 10))
 where access_code is null or access_code = '';
alter table public.pawahauz_sites alter column access_code set default upper(substr(md5(gen_random_uuid()::text), 1, 10));
create unique index if not exists pawahauz_sites_access_code_idx on public.pawahauz_sites (access_code);

alter table public.pawahauz_surveys add column if not exists edit_token    uuid not null default gen_random_uuid();
alter table public.pawahauz_surveys add column if not exists submitted_via text not null default 'platform';

-- Site name for a valid link code (nothing else is exposed)
create or replace function public.pawahauz_site_by_code(p_code text)
returns table(id uuid, name text, address text)
language sql stable security definer set search_path = public as $$
  select s.id, s.name, s.address from public.pawahauz_sites s
   where length(coalesce(p_code,'')) >= 6 and s.access_code = upper(trim(p_code));
$$;

-- Submit a new survey through a link code; returns id, ref_no and a private edit token
create or replace function public.pawahauz_submit_survey(p_code text, p_data jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_site uuid; v_ref text; v_id uuid; v_tok uuid;
begin
  if length(coalesce(p_code,'')) < 6 then raise exception 'This survey link is not valid'; end if;
  select id into v_site from public.pawahauz_sites where access_code = upper(trim(p_code));
  if v_site is null then raise exception 'This survey link is not valid any more'; end if;
  if length(p_data::text) > 200000 then raise exception 'Survey is too large'; end if;
  v_ref := public.next_pawahauz_survey_ref();
  insert into public.pawahauz_surveys (site_id, ref_no, survey_date, surveyor, resident_name, phone, email, unit_no, floor, apt_type,
      occupants, occupancy, grid_band, grid_hours, grid_spend, backup_type, backup_size, fuel_spend, gen_hours,
      interest, pay_pref, max_spend, supply_hours, appliances, notes, daily_kwh, peak_w, created_by, submitted_via)
  select v_site, v_ref, coalesce(r.survey_date, current_date), coalesce(r.surveyor,''), coalesce(r.resident_name,''), coalesce(r.phone,''),
      coalesce(r.email,''), coalesce(r.unit_no,''), coalesce(r.floor,''), coalesce(r.apt_type,''),
      coalesce(r.occupants,0), coalesce(r.occupancy,''), coalesce(r.grid_band,''), coalesce(r.grid_hours,0), coalesce(r.grid_spend,0),
      coalesce(r.backup_type,'None'), coalesce(r.backup_size,''), coalesce(r.fuel_spend,0), coalesce(r.gen_hours,0),
      coalesce(r.interest,''), coalesce(r.pay_pref,''), coalesce(r.max_spend,0), coalesce(r.supply_hours,''),
      coalesce(r.appliances,'[]'::jsonb), coalesce(r.notes,''), coalesce(r.daily_kwh,0), coalesce(r.peak_w,0),
      'field link' || case when coalesce(r.surveyor,'') <> '' then ': ' || r.surveyor else '' end, 'field link'
    from jsonb_populate_record(null::public.pawahauz_surveys, p_data) r
  returning id, edit_token into v_id, v_tok;
  return jsonb_build_object('id', v_id, 'ref_no', v_ref, 'edit_token', v_tok);
end $$;

-- Update a survey submitted through a link (needs its edit token)
create or replace function public.pawahauz_update_survey(p_id uuid, p_token uuid, p_data jsonb)
returns void language plpgsql security definer set search_path = public as $$
declare r public.pawahauz_surveys;
begin
  if length(p_data::text) > 200000 then raise exception 'Survey is too large'; end if;
  r := jsonb_populate_record(null::public.pawahauz_surveys, p_data);
  update public.pawahauz_surveys s set
      survey_date = coalesce(r.survey_date, s.survey_date), surveyor = coalesce(r.surveyor,''),
      resident_name = coalesce(r.resident_name,''), phone = coalesce(r.phone,''), email = coalesce(r.email,''),
      unit_no = coalesce(r.unit_no,''), floor = coalesce(r.floor,''), apt_type = coalesce(r.apt_type,''),
      occupants = coalesce(r.occupants,0), occupancy = coalesce(r.occupancy,''),
      grid_band = coalesce(r.grid_band,''), grid_hours = coalesce(r.grid_hours,0), grid_spend = coalesce(r.grid_spend,0),
      backup_type = coalesce(r.backup_type,'None'), backup_size = coalesce(r.backup_size,''), fuel_spend = coalesce(r.fuel_spend,0),
      gen_hours = coalesce(r.gen_hours,0), interest = coalesce(r.interest,''), pay_pref = coalesce(r.pay_pref,''),
      max_spend = coalesce(r.max_spend,0), supply_hours = coalesce(r.supply_hours,''),
      appliances = coalesce(r.appliances,'[]'::jsonb), notes = coalesce(r.notes,''),
      daily_kwh = coalesce(r.daily_kwh,0), peak_w = coalesce(r.peak_w,0), updated_at = now()
   where s.id = p_id and s.edit_token = p_token;
  if not found then raise exception 'Survey not found'; end if;
end $$;

-- Re-open a survey submitted through a link (needs its edit token)
create or replace function public.pawahauz_get_survey(p_id uuid, p_token uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select to_jsonb(s) - 'edit_token' - 'created_by'
    from public.pawahauz_surveys s where s.id = p_id and s.edit_token = p_token;
$$;

revoke all on function public.pawahauz_site_by_code(text)                from public;
revoke all on function public.pawahauz_submit_survey(text, jsonb)        from public;
revoke all on function public.pawahauz_update_survey(uuid, uuid, jsonb)  from public;
revoke all on function public.pawahauz_get_survey(uuid, uuid)            from public;
grant execute on function public.pawahauz_site_by_code(text)               to anon, authenticated;
grant execute on function public.pawahauz_submit_survey(text, jsonb)       to anon, authenticated;
grant execute on function public.pawahauz_update_survey(uuid, uuid, jsonb) to anon, authenticated;
grant execute on function public.pawahauz_get_survey(uuid, uuid)           to anon, authenticated;
-- next_pawahauz_survey_ref is only called from inside the functions above
revoke all on function public.next_pawahauz_survey_ref() from public, anon;
grant execute on function public.next_pawahauz_survey_ref() to authenticated;
