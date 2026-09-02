do $$
begin
  if exists (select 1 from public.project_sites where site_no = 'KIRU-SITE-0001') then
    raise notice 'Project sites already seeded - skipping.';
    return;
  end if;

  insert into public.project_sites (site_no, shop_location, state_region, contact_person, phone_number, lease_term, stage) values
    ('KIRU-SITE-0001', 'Ochanja Market, Anambra State', 'Onitsha, Anambra State', 'Goodluck Ngwube', '234 816 588 9615', 'March 2026 - March 2029', 'Site Survey'),
    ('KIRU-SITE-0002', 'Port Harcourt Road, Alaoji Aba', 'Alaoji Aba', 'Goodluck Ngwube', '234 816 588 9615', 'March 2026 - March 2029', 'Site Survey'),
    ('KIRU-SITE-0003', 'Igbudu Market, Warri', 'Warri, Delta State', 'Martins Ochimana', '234 905 726 8939', 'March 2026 - March 2029', 'Site Survey'),
    ('KIRU-SITE-0004', 'Agbado for Asset Growth', 'Sango, Ogun State', 'Abiodun Aranilewa', '234 706 259 1735', 'June 2026 - June 2029', 'Site Survey'),
    ('KIRU-SITE-0005', 'Agege Oniwaya Market, Lagos', 'Lagos State', 'Wasiu Olayiwola', '234 806 448 7984', '3 years', 'Site Survey'),
    ('KIRU-SITE-0006', 'Amu Market, Olurunsogo, Mushin', 'Lagos State', 'Temitope Showunmi', '234 803 922 0453', '', 'Site Survey'),
    ('KIRU-SITE-0007', 'Ahijo Plaza, ASPAMDA Market', 'Lagos State', 'Olayemi Ayetigbo', '234 813 094 2692', '2026 - 2029', 'Site Survey'),
    ('KIRU-SITE-0008', 'C5 Onuigbo Plaza, Asaba', 'Asaba, Delta State', 'Henry Agbogu', '234 814 811 1524', 'March 2026 - March 2029', 'Site Survey');
end $$;
