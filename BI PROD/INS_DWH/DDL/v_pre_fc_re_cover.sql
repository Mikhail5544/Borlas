create or replace force view ins_dwh.v_pre_fc_re_cover as
select nvl(dm_ph.policy_header_id, -1) policy_header_id,
       nvl(dm_rt.risk_type_id, -1) risk_type_id,
       (case
         when months_between(pp.end_date + 1, ph.start_date) > 12 then
          case
         when gt.life_property = 1 then
          2
         when gt.life_property = 0 then
          4
         else
          -1
       end else case
          when gt.life_property = 1 then
           1
          when gt.life_property = 0 then
           3
          else
           -1
        end end) risk_type_gaap_id,
       nvl(dm_assured.contact_id, -1) assured_contact_id,
       nvl(dm_insurer.contact_id, -1) insured_contact_id,
       bp.reinsurer_id reinsurer_contact_id,
       rcalc.first_ins_guarantee first_ins_guarantee --�������������� ��������� �����������
      ,
       rcalc.ins_guarantee -- ��������� ����������� ��� ������
      ,
       rc.part_sum --���� ���������������
      ,
       rcalc.reins_guarantee -- ���������������� �����������
      ,
       rcalc.re_tariff -- ���������������� �����
      ,
       rrb.brutto_premium --������-������
      ,
       rrb.netto_premium --�����-������
      ,
       rrb.commission --��������
      ,
       0 charge_repremium_rsbu --����������� ������ ���-�� ����
      ,
       0 charge_commission_rsbu--����������� �������� ���-�� ����
      ,
       0 charge_repremium_ifrs --����������� ������ ���-�� ����
      ,
       0 charge_commission_ifrs --����������� �������� ���-�� ����
      ,
       f.brief fund --�� ������
      ,
       bp.num --����� ������ �������
      ,
       bt.name --��� ������ �������
      ,
       ins.doc.get_doc_status_name(bp.re_bordero_package_id) status --������ ������ ��������
      ,
       bp.start_date --���� ������ ������ �������
      ,
       bp.end_date, --���� ��������� ������ �������
              pc.p_cover_id,
              rc.re_cover_id
              ,

              sysdate created_date,
              sysdate modified_date

--������ ����
--���� ��� ������
  from ins.re_cover rc,
       ins.rel_recover_bordero rrb,
       ins.re_bordero b,
       ins.re_bordero_type bt,
       ins.ven_re_bordero_package bp,
       ins.re_calculation rcalc,
       ins.fund f,
       ins.entity e,
       ins.p_cover pc,
       dm_contact dm_insurer,
       dm_contact dm_assured,
       dm_p_pol_header dm_ph,
       dm_risk_type dm_rt,
       ins.ven_as_assured aa,
       ins.p_pol_header ph,
       ins.ven_p_policy pp,
       ins.t_prod_line_option plo,
       ins.gaap_pl_types gt,
       (select polc.policy_id, polc.contact_id
          from ins.p_policy_contact polc, ins.t_contact_pol_role pr
         where polc.contact_policy_role_id = pr.id
           and pr.brief = '������������') insurers

 where pc.p_cover_id = rc.p_cover_id
   and dm_ph.policy_header_id(+) = ph.policy_header_id
   and dm_rt.risk_type_id(+) = pc.t_prod_line_option_id
   and dm_insurer.contact_id(+) = insurers.contact_id
   and dm_assured.contact_id(+) = aa.assured_contact_id
   and pc.as_asset_id = aa.as_assured_id
   and aa.p_policy_id = pp.policy_id
   and pp.pol_header_id = ph.policy_header_id
   and insurers.policy_id = pp.policy_id
   and pc.t_prod_line_option_id = plo.id
   and plo.id = pc.t_prod_line_option_id
   and gt.id(+) = plo.product_line_id
   and rrb.re_cover_id = rc.re_cover_id
   and b.fund_id = f.fund_id (+)
   and b.re_bordero_id = rrb.re_bordero_id --�������
   and bp.re_bordero_package_id = b.re_bordero_package_id --����� �������
   and bp.start_date =
       (select max(c.start_date)
          from ins.re_bordero_package c
         where c.re_m_contract_id = bp.re_m_contract_id)
   and bt.re_bordero_type_id = b.re_bordero_type_id --��� �������
   and e.brief = 'REL_RECOVER_BORDERO'
   and rcalc.ure_id = e.ent_id
   and rcalc.uro_id = rrb.rel_recover_bordero_id
--  )
-- /*
union all
select nvl(dm_ph.policy_header_id, -1) policy_header_id,
       nvl(dm_rt.risk_type_id, -1) risk_type_id,
       (case
         when months_between(pp.end_date + 1, ph.start_date) > 12 then
          case
         when gt.life_property = 1 then
          2
         when gt.life_property = 0 then
          4
         else
          -1
       end else case
          when gt.life_property = 1 then
           1
          when gt.life_property = 0 then
           3
          else
           -1
        end end) risk_type_gaap_id,
       nvl(dm_assured.contact_id, -1) assured_contact_id,
       nvl(dm_insurer.contact_id, -1) insured_contact_id,
       sh.reinsurer_id reinsurer_contact_id,
       0 first_ins_guarantee --�������������� ��������� �����������
      ,
       0 ins_guarantee -- ��������� ����������� ��� ������
      ,
       rc.part_sum --���� ���������������
      ,
       0 reins_guarantee --���������������� �����������
      ,
       rc.re_tarif --���������������� �����
      ,
       rc.brutto_premium --������-������
      ,
       rc.netto_premium --�����-������
      ,
       rc.commission --��������
      ,
       0 charge_repremium_rsbu --����������� ������ ���-�� ����
      ,
       0 charge_commission_rsbu--����������� �������� ���-�� ����
      ,
       0 charge_repremium_ifrs --����������� ������ ���-�� ����
      ,
       0 charge_commission_ifrs --����������� �������� ���-�� ����
      ,
       f.brief fund --�� ������
      ,
       s.num --����� ������ ������� (�����)
      ,
       '����' name --��� ������ ������� (�����)
      ,
       ins.doc.get_doc_status_name(s.re_slip_id) status --������ ������ �������� (�����)
      ,
       s.start_date --���� ������ ������ �������
      ,
       s.end_date --���� ��������� ������ �������
       ,
                    pc.p_cover_id,
              rc.re_cover_id
              ,

              sysdate created_date ,
               sysdate modified_date

--������ ����
--���� ��� ������
  from ins.re_cover rc,
       ins.ven_re_slip s,
       ins.re_slip_header sh,
       ins.p_cover pc,
       ins.fund f,
       dm_contact dm_insurer,
       dm_contact dm_assured,
       dm_p_pol_header dm_ph,
       dm_risk_type dm_rt,
       ins.ven_as_assured aa,
       ins.p_pol_header ph,
       ins.ven_p_policy pp,
       ins.t_prod_line_option plo,
       ins.gaap_pl_types gt,
       (select polc.policy_id, polc.contact_id
          from ins.p_policy_contact polc, ins.t_contact_pol_role pr
         where polc.contact_policy_role_id = pr.id
           and pr.brief = '������������') insurers

 where pc.p_cover_id = rc.p_cover_id
   and dm_ph.policy_header_id(+) = ph.policy_header_id
   and dm_rt.risk_type_id(+) = pc.t_prod_line_option_id
   and dm_insurer.contact_id(+) = insurers.contact_id
   and dm_assured.contact_id(+) = aa.assured_contact_id
   and sh.fund_id = f.fund_id (+)
   and pc.as_asset_id = aa.as_assured_id
   and aa.p_policy_id = pp.policy_id
   and pp.pol_header_id = ph.policy_header_id
   and insurers.policy_id = pp.policy_id
   and pc.t_prod_line_option_id = plo.id
   and plo.id = pc.t_prod_line_option_id
   and gt.id(+) = plo.product_line_id
   and rc.re_slip_id = s.re_slip_id
   and sh.last_slip_id = s.re_slip_id
--)
--*/

--select * from ins.ven_re_slip_header
-- select * from ins.re_cover
;

