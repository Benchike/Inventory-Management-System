do $$
begin
  if exists (select 1 from public.lif_expenses where ref = 'KIRU-EXP-0001') then
    raise notice 'LIF Q1 expenses already seeded - skipping.';
    return;
  end if;

  insert into public.lif_expenses (ref, expense_date, category, description, amount, fx_rate) values
    ('KIRU-EXP-0001', '2026-04-01', 'Operating / Digital Services', 'ChatGPT Subscription', 35000, 1591.95),
    ('KIRU-EXP-0002', '2026-04-01', 'Installation / Site Labour', 'Installers Charge', 50000, 1591.95),
    ('KIRU-EXP-0003', '2026-04-01', 'Logistics / Site Expense', 'Material Logistics To Enugu', 58000, 1591.95),
    ('KIRU-EXP-0004', '2026-04-04', 'Logistics / Site Expense', 'Transportation Fare To Lagos', 135000, 1588.77),
    ('KIRU-EXP-0005', '2026-04-06', 'Installation / Site Labour', 'Installers Charge', 78000, 1586.41),
    ('KIRU-EXP-0006', '2026-04-08', 'Installation / Site Labour', 'Installers Charge', 5000, 1597.13),
    ('KIRU-EXP-0007', '2026-04-08', 'Installation / Site Labour', 'Installers Charge', 5000, 1597.13),
    ('KIRU-EXP-0008', '2026-04-08', 'Installation / Site Labour', 'Installers Charge', 20000, 1597.13),
    ('KIRU-EXP-0009', '2026-04-12', 'Logistics / Site Expense', 'Material Logistics', 92000, 1592.41),
    ('KIRU-EXP-0010', '2026-04-14', 'Fixed Asset / Field Equipment', 'Label Printer for Equipment Labelling', 95000, 1591.51),
    ('KIRU-EXP-0011', '2026-04-14', 'Installation / Site Labour', 'Installers Charge for 6kVA Idumota', 220000, 1591.51),
    ('KIRU-EXP-0012', '2026-04-21', 'Logistics / Site Expense', 'Logistics To Abuja And Lagos', 20000, 1583.86),
    ('KIRU-EXP-0013', '2026-04-25', 'Installation / Site Labour', 'Installers Charge', 30000, 1583.58),
    ('KIRU-EXP-0014', '2026-04-25', 'Installation / Site Labour', 'Installers Charge', 35000, 1583.58),
    ('KIRU-EXP-0015', '2026-04-25', 'Fixed Asset / Communication', 'Redmi 15C Smartphone', 160000, 1583.58),
    ('KIRU-EXP-0016', '2026-04-26', 'Logistics / Site Expense', 'Tfare Of 5X 610W Panels To Idumota', 45000, 1589.4),
    ('KIRU-EXP-0017', '2026-04-26', 'Logistics / Site Expense', 'Tfare To Site And Office', 50000, 1589.4),
    ('KIRU-EXP-0018', '2026-04-28', 'Installation / Site Labour', 'Installer Charge', 6000, 1590.9),
    ('KIRU-EXP-0019', '2026-04-28', 'Logistics / Site Expense', 'Logistics / Site Expense', 23000, 1590.9),
    ('KIRU-EXP-0020', '2026-04-29', 'Installation / Site Labour', 'Installation / Site Labour', 100000, 1600.13),
    ('KIRU-EXP-0021', '2026-04-30', 'Bank / Operating Cost', 'Account Maintenance Fee', 8476, 1607.41),
    ('KIRU-EXP-0022', '2026-05-02', 'Logistics / Site Expense', 'Transport And Logistics', 7000, 1613.13),
    ('KIRU-EXP-0023', '2026-05-06', 'Installation / Site Labour', 'Installers Charge', 62000, 1600.44),
    ('KIRU-EXP-0024', '2026-05-10', 'Installation / Site Labour', 'Installer charge', 100000, 1601.49),
    ('KIRU-EXP-0025', '2026-05-11', 'Installation / Site Labour', 'Installation Charge for installer', 20000, 1600.95),
    ('KIRU-EXP-0026', '2026-05-11', 'Installation / Site Labour', 'Accessories and Installer Charge', 100000, 1600.95),
    ('KIRU-EXP-0027', '2026-05-11', 'Installation / Site Labour', 'Installation Charge', 100000, 1600.95),
    ('KIRU-EXP-0028', '2026-05-13', 'Installation / Site Labour', 'Installers Charge', 110000, 1606.44),
    ('KIRU-EXP-0029', '2026-05-13', 'Installation / Site Labour', 'Installers Charge', 131000, 1606.44),
    ('KIRU-EXP-0030', '2026-05-13', 'Logistics / Site Expense', 'Domain Renew, Internet & Logistics', 180000, 1606.44),
    ('KIRU-EXP-0031', '2026-05-15', 'Logistics / Site Expense', 'Logistics', 37000, 1601.85),
    ('KIRU-EXP-0032', '2026-05-15', 'Logistics / Site Expense', 'Logistics And Site Expenses', 61000, 1601.85),
    ('KIRU-EXP-0033', '2026-05-16', 'Installation / Site Labour', 'Installer Charge And Logistics', 50000, 1593.3),
    ('KIRU-EXP-0034', '2026-05-16', 'Installation / Site Labour', 'Installer Charge', 100000, 1593.3),
    ('KIRU-EXP-0035', '2026-05-17', 'Installation / Site Labour', 'Installer charge and site expenses', 120000, 1592.53),
    ('KIRU-EXP-0036', '2026-05-17', 'Installation / Site Labour', 'Installer Charge', 145000, 1592.53),
    ('KIRU-EXP-0037', '2026-05-21', 'Installation / Site Labour', 'Installers Charge', 70000, 1592.48),
    ('KIRU-EXP-0038', '2026-05-21', 'Fixed Asset / Field Equipment', 'DJI Neo 2 Drone', 690000, 1592.48),
    ('KIRU-EXP-0039', '2026-05-28', 'Logistics / Site Expense', 'Transport, Logistics And Subscriti', 100000, 1597.82),
    ('KIRU-EXP-0040', '2026-05-29', 'Installation / Site Labour', 'Installers Charge', 60000, 1596.93),
    ('KIRU-EXP-0041', '2026-05-30', 'Logistics / Site Expense', 'Logistics', 40000, 1597.09),
    ('KIRU-EXP-0042', '2026-05-31', 'Bank / Operating Cost', 'Account Maintenance Fee', 19941, 1598.79),
    ('KIRU-EXP-0043', '2026-06-01', 'Installation / Site Labour', 'Installer Charge', 140000, 1598.67),
    ('KIRU-EXP-0044', '2026-06-04', 'Logistics / Site Expense', 'Logistics And Transportation', 50000, 1584.03),
    ('KIRU-EXP-0045', '2026-06-08', 'Installation / Site Labour', 'Installers Charge', 100000, 1566.1),
    ('KIRU-EXP-0046', '2026-06-09', 'Safety / Field Equipment', 'Body Harness for Safety', 42000, 1568.79),
    ('KIRU-EXP-0047', '2026-06-10', 'Logistics / Site Expense', 'Logistics And Transportation', 50000, 1570.23),
    ('KIRU-EXP-0048', '2026-06-12', 'Vehicle / Operating Cost', 'Car Inspection', 40000, 1570.96),
    ('KIRU-EXP-0049', '2026-06-13', 'Logistics / Site Expense', 'Transport, Logistics Ngn 20,000.00 Ngn 1,367,820.36 1781340832395/Cib//Nip Tfr To Joseph Adouozava Alleh/Opay', 20000, 1573.2),
    ('KIRU-EXP-0050', '2026-06-16', 'Printing / Marketing', 'Flyer Printing', 10000, 1576.73),
    ('KIRU-EXP-0051', '2026-06-16', 'Vehicle / Operating Cost', 'Vehicle Inspection', 92000, 1576.73),
    ('KIRU-EXP-0052', '2026-06-16', 'Installation / Site Labour', 'Installers Charge', 160000, 1576.73),
    ('KIRU-EXP-0053', '2026-06-18', 'Printing / Marketing', 'Flyer Printing', 10000, 1573.11),
    ('KIRU-EXP-0054', '2026-06-18', 'Vehicle / Operating Cost', 'Vehicle Registration', 125000, 1573.11),
    ('KIRU-EXP-0055', '2026-06-18', 'Installation / Site Labour', 'Installers Charge', 150000, 1573.11),
    ('KIRU-EXP-0056', '2026-06-20', 'Vehicle / Operating Cost', 'Company Vehicle Servicing', 167000, 1559.74),
    ('KIRU-EXP-0057', '2026-06-28', 'Operating / Digital Services', 'TRF TO BENEDICT CHIBUIKEM', 34000, 1567.22),
    ('KIRU-EXP-0058', '2026-06-28', 'Operating / Digital Services', 'ChatGPT Subscription', 35000, 1567.22),
    ('KIRU-EXP-0059', '2026-06-30', 'Bank / Operating Cost', 'Account Maintenance Fee', 5060, 1565.34),
    ('KIRU-EXP-0060', '2026-06-30', 'Logistics / Site Expense', 'Logistics And Transportation', 20000, 1565.34);

  insert into public.lif_expense_counters(counter_key, value) values ('global', 60)
    on conflict (counter_key) do update set value = greatest(public.lif_expense_counters.value, 60);

end $$;