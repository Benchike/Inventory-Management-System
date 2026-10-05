-- ============================================================
-- PAWAHAUZ SURVEY — GRID POWER AVAILABLE (Yes / No)
-- Run once in Supabase → SQL Editor → New query. Safe to re-run.
-- Requires add_pawahauz_survey.sql and add_pawahauz_field_link.sql first.
-- ============================================================

alter table public.pawahauz_surveys add column if not exists grid_available text not null default '';
update public.pawahauz_surveys set grid_available = 'Yes'
 where grid_available = '' and (grid_band <> '' or grid_hours > 0 or grid_spend > 0);

-- field-link functions now store grid_available too
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
      occupants, occupancy, grid_available, grid_band, grid_hours, grid_spend, backup_type, backup_size, fuel_spend, gen_hours,
      interest, pay_pref, max_spend, supply_hours, appliances, notes, daily_kwh, peak_w, created_by, submitted_via)
  select v_site, v_ref, coalesce(r.survey_date, current_date), coalesce(r.surveyor,''), coalesce(r.resident_name,''), coalesce(r.phone,''),
      coalesce(r.email,''), coalesce(r.unit_no,''), coalesce(r.floor,''), coalesce(r.apt_type,''),
      coalesce(r.occupants,0), coalesce(r.occupancy,''), coalesce(r.grid_available,''), coalesce(r.grid_band,''), coalesce(r.grid_hours,0), coalesce(r.grid_spend,0),
      coalesce(r.backup_type,'None'), coalesce(r.backup_size,''), coalesce(r.fuel_spend,0), coalesce(r.gen_hours,0),
      coalesce(r.interest,''), coalesce(r.pay_pref,''), coalesce(r.max_spend,0), coalesce(r.supply_hours,''),
      coalesce(r.appliances,'[]'::jsonb), coalesce(r.notes,''), coalesce(r.daily_kwh,0), coalesce(r.peak_w,0),
      'field link' || case when coalesce(r.surveyor,'') <> '' then ': ' || r.surveyor else '' end, 'field link'
    from jsonb_populate_record(null::public.pawahauz_surveys, p_data) r
  returning id, edit_token into v_id, v_tok;
  return jsonb_build_object('id', v_id, 'ref_no', v_ref, 'edit_token', v_tok);
end $$;

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
      grid_available = coalesce(r.grid_available,''), grid_band = coalesce(r.grid_band,''), grid_hours = coalesce(r.grid_hours,0), grid_spend = coalesce(r.grid_spend,0),
      backup_type = coalesce(r.backup_type,'None'), backup_size = coalesce(r.backup_size,''), fuel_spend = coalesce(r.fuel_spend,0),
      gen_hours = coalesce(r.gen_hours,0), interest = coalesce(r.interest,''), pay_pref = coalesce(r.pay_pref,''),
      max_spend = coalesce(r.max_spend,0), supply_hours = coalesce(r.supply_hours,''),
      appliances = coalesce(r.appliances,'[]'::jsonb), notes = coalesce(r.notes,''),
      daily_kwh = coalesce(r.daily_kwh,0), peak_w = coalesce(r.peak_w,0), updated_at = now()
   where s.id = p_id and s.edit_token = p_token;
  if not found then raise exception 'Survey not found'; end if;
end $$;
