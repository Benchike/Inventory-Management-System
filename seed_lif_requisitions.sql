-- ============================================================
-- Seed LIF Requisitions (drafts) from the Deployment Cost Capital Report
-- Requested by: Joseph Alleh · Purpose: New Project
-- Approved by: Benedict Okpala · Approver title: CEO
-- Status: draft (staged for review/edit before issuing)
-- Safe to re-run: skips entirely if this batch already exists.
-- ============================================================
do $$
begin
  if exists (select 1 from public.lif_documents where kind='mro' and requested_by='Joseph Alleh' and purpose='New Project') then
    raise notice 'Requisitions already staged from the Deployment Cost Report - skipping.';
    return;
  end if;

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-01', 'draft', 'Joseph Alleh', 'Global New Life', 'New Project',
    'Balance of system (BOS) lot from report: ₦255,000 — select specific BOS/Accessories items manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '600W Monofacial Solar Panel'), 'qty', 2, 'cost', 155000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-02', 'draft', 'Joseph Alleh', 'Coco Extension', 'New Project',
    'Balance of system (BOS) lot from report: ₦95,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦80,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '590W Bifacial Solar Panel'), 'qty', 1, 'cost', 150000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-04', 'draft', 'Joseph Alleh', 'Henry Ezeobi', 'New Project',
    'Balance of system (BOS) lot from report: ₦255,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦80,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 6, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 550000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '5kWh, 48V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 1100000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-07', 'draft', 'Joseph Alleh', 'Spine Product LTD', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 350000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-07', 'draft', 'Joseph Alleh', 'Benvic Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-09', 'draft', 'Joseph Alleh', 'Sir Ken Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦130,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 1, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-11', 'draft', 'Joseph Alleh', 'God of Elijah Enterprise', 'New Project',
    'Balance of system (BOS) lot from report: ₦120,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 1, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 350000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-13', 'draft', 'Joseph Alleh', 'Rotanna Bolagab Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦395,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 8, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 600000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '5kWh, 48V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 1100000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-15', 'draft', 'Joseph Alleh', 'Cellent Medicals', 'New Project',
    'Balance of system (BOS) lot from report: ₦95,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '600W Monofacial Solar Panel'), 'qty', 1, 'cost', 150000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-16', 'draft', 'Joseph Alleh', 'Sunshade Global Enterprise', 'New Project',
    'Balance of system (BOS) lot from report: ₦209,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 2, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.5kW , 12V Hybrid Inverter'), 'qty', 1, 'cost', 220000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2.5kWh, 24V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 390000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-17', 'draft', 'Joseph Alleh', 'Cashmed Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-23', 'draft', 'Joseph Alleh', 'Great God Venture', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-23', 'draft', 'Joseph Alleh', 'Ruzu Bitters', 'New Project',
    'Balance of system (BOS) lot from report: ₦115,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 1, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 340000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-25', 'draft', 'Joseph Alleh', 'Herbolly Nigeria Enterprise', 'New Project',
    'Balance of system (BOS) lot from report: ₦130,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 1, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-25', 'draft', 'Joseph Alleh', 'Raji Lukmon', 'New Project',
    'Balance of system (BOS) lot from report: ₦195,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 4, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.2kW + 3.6kWh Solar Generator'), 'qty', 1, 'cost', 750000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-28', 'draft', 'Joseph Alleh', 'Avarta Kacee', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-04-29', 'draft', 'Joseph Alleh', 'Chidera Udegbunam', 'New Project',
    'Balance of system (BOS) lot from report: ₦235,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 3, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2kW, 12V Hybrid Inverter'), 'qty', 1, 'cost', 250000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3.8kWh, 24V Lithium Battery (Ground Mount)'), 'qty', 1, 'cost', 490000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-02', 'draft', 'Joseph Alleh', 'Omar Global Venture', 'New Project',
    'Balance of system (BOS) lot from report: ₦235,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 4, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.2kW + 3.6kWh Solar Generator'), 'qty', 1, 'cost', 750000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-04', 'draft', 'Joseph Alleh', 'De Stan Mega Enterprises', 'New Project',
    'Balance of system (BOS) lot from report: ₦225,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '590W Bifacial Solar Panel'), 'qty', 3, 'cost', 150000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.2kW + 3.6kWh Solar Generator'), 'qty', 1, 'cost', 780000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-05', 'draft', 'Joseph Alleh', 'C Emmanuel Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦225,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 2, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.5kW , 12V Hybrid Inverter'), 'qty', 1, 'cost', 220000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2.5kWh, 24V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 390000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-07', 'draft', 'Joseph Alleh', 'Dave Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦245,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 3, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2kW, 12V Hybrid Inverter'), 'qty', 1, 'cost', 250000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2.5kWh, 24V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 390000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-11', 'draft', 'Joseph Alleh', 'Mega Drugs LTD', 'New Project',
    'Balance of system (BOS) lot from report: ₦315,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 3, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2kW, 12V Hybrid Inverter'), 'qty', 1, 'cost', 250000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3.8kWh, 24V Lithium Battery (Ground Mount)'), 'qty', 1, 'cost', 490000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-11', 'draft', 'Joseph Alleh', 'Nnaemeka Pascal Ikezuagu', 'New Project',
    'Balance of system (BOS) lot from report: ₦215,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 3, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.2kW + 3.6kWh Solar Generator'), 'qty', 1, 'cost', 750000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-12', 'draft', 'Joseph Alleh', 'Samuel Duru', 'New Project',
    'Balance of system (BOS) lot from report: ₦240,000 — select specific BOS/Accessories items manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 650000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '16kWh, 48V Lvtopsun Lithium Battery'), 'qty', 1, 'cost', 2750000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-13', 'draft', 'Joseph Alleh', 'Samarac Communications', 'New Project',
    'Balance of system (BOS) lot from report: ₦285,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '455W Monofacial Solar Panel'), 'qty', 3, 'cost', 115000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3kW, 24V Hybrid Inverter'), 'qty', 1, 'cost', 330000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2.5kWh, 24V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 600000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-15', 'draft', 'Joseph Alleh', 'Remac Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦235,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 2, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2kW, 12V Hybrid Inverter'), 'qty', 1, 'cost', 250000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3.8kWh, 24V Lithium Battery (Ground Mount)'), 'qty', 1, 'cost', 530000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-16', 'draft', 'Joseph Alleh', 'Jonathan Chukwu', 'New Project',
    'Balance of system (BOS) lot from report: ₦315,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '630W Bifacial Solar Panel'), 'qty', 6, 'cost', 158000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 600000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '5kWh, 48V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 1100000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-18', 'draft', 'Joseph Alleh', 'Arose Pharmacy', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-20', 'draft', 'Joseph Alleh', 'CO Ematex Divine Concept LTD', 'New Project',
    'Balance of system (BOS) lot from report: ₦125,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 1, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-22', 'draft', 'Joseph Alleh', 'Darlington Onyemere', 'New Project',
    'Balance of system (BOS) lot from report: ₦165,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '630W Bifacial Solar Panel'), 'qty', 1, 'cost', 160000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 330000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-28', 'draft', 'Joseph Alleh', 'Amarachi Onyenagubo', 'New Project',
    'Balance of system (BOS) lot from report: ₦81,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '1.5kW + 4kWh Solar Generator'), 'qty', 1, 'cost', 850000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-28', 'draft', 'Joseph Alleh', 'Michael Chinedu', 'New Project',
    'Balance of system (BOS) lot from report: ₦25,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '500W + 1kWh Solar Generator'), 'qty', 1, 'cost', 280000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-05-31', 'draft', 'Joseph Alleh', 'Joy Ifeoma Asolo', 'New Project',
    'Balance of system (BOS) lot from report: ₦255,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '365W Monofacial Panel'), 'qty', 4, 'cost', 105000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2kW, 12V Hybrid Inverter'), 'qty', 1, 'cost', 250000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3.8kWh, 24V Lithium Battery (Ground Mount)'), 'qty', 1, 'cost', 530000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-06-07', 'draft', 'Joseph Alleh', 'U3C Comestics', 'New Project',
    'Panel capacity in report was 620W (qty 5); catalogue has no 620W item, substituted 610W Bifacial Solar Panel — verify before issuing. Balance of system (BOS) lot from report: ₦278,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 5, 'cost', 158000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '4kW, 24V Hybrid Inverter'), 'qty', 1, 'cost', 420000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '5kWh, 48V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 980000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-06-16', 'draft', 'Joseph Alleh', 'Silver and Gold Nig. LTD', 'New Project',
    'Balance of system (BOS) lot from report: ₦327,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 5, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 545000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '5kWh, 48V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 910000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-06-17', 'draft', 'Joseph Alleh', 'Elevance Solutions LTD', 'New Project',
    'Balance of system (BOS) lot from report: ₦365,000 — select specific BOS/Accessories items manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '610W Bifacial Solar Panel'), 'qty', 6, 'cost', 155000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '6kW, 48V Hybrid Inverter'), 'qty', 1, 'cost', 545000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '10kWh, 48V Lithium Battery'), 'qty', 1, 'cost', 1750000)
    ),
    'Benedict Okpala', 'CEO');

  insert into public.lif_documents (kind, no, doc_date, status, requested_by, project, purpose, note, lines, approved_by, approver_title)
  values ('mro', public.lif_next_doc_no('mro'), '2026-06-29', 'draft', 'Joseph Alleh', 'Urch Delight Enterprise', 'New Project',
    'Balance of system (BOS) lot from report: ₦235,000 — select specific BOS/Accessories items manually. IoT monitor from report: ₦47,000 (qty 1) — select specific IoT & Monitoring item manually.',
    jsonb_build_array(
      jsonb_build_object('itemId', (select id from public.lif_items where name = '590W Bifacial Solar Panel'), 'qty', 4, 'cost', 150000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '3kW, 24V Hybrid Inverter'), 'qty', 1, 'cost', 330000),
      jsonb_build_object('itemId', (select id from public.lif_items where name = '2.5kWh, 24V Lithium Battery (Wall Mount)'), 'qty', 1, 'cost', 600000)
    ),
    'Benedict Okpala', 'CEO');

end $$;