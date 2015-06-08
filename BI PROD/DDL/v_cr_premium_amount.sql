CREATE OR REPLACE FORCE VIEW V_CR_PREMIUM_AMOUNT
(polisy_id, status_pol, pol_ser, pol_num, contract_num, start_date, end_date, programm_kode, main_programm_name, programm_name, fee_payment_term, ins_year, due_date, is_full_amont, reg_date_doc, type_doc, amount, fio_aggent, ag_type, ag_contr_num, agent_liader, period, premium, is_pbul, date_underrating, date_activate, fund, fund_pay, ag_st, aglead_st, kv, kvlead)
AS
SELECT pp.policy_id, -- �� ������
       Doc.get_doc_status_name(pp.policy_id),-- ������ �������� �� ������ ��������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num,-- ����� ��������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� ��������
       tLob.brief,-- ��� ���������
       pr.description,-- �������
       tPrLn.description,-- ��������� (�������� �����)
       pp.fee_payment_term,-- ������ ������ (� �����)
       TO_CHAR(CEIL(MONTHS_BETWEEN(SYSDATE,ph.start_date)/12)) AS ins_year,-- ������� ��� �������� ��������
       sch.due_date,-- ���� ������ �� ������� ��������
       DECODE(dof.set_off_amount,sch.part_amount,'��','���') AS is_full_amount,-- ������ �������� ���������?
       ap1.due_date,-- ���� ��������� ������
       ap1.doc_templ_id, -- id ���� ��������� ������
       dof.set_off_amount, -- ����� �������
       Ent.obj_name('CONTACT',agch.agent_id) AS agent,-- ��� ������
       agCatAg.category_name, -- ��� ������
       agch.num, -- ����� ���������� ��������
       Ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- ��� ������������ ������
       tpt.description,-- �������������
       sch.part_amount,-- ����� ������
       DECODE(agc.leg_pos,1,'��','���') AS is_pbul,-- �������� �� ����� �����?
       Doc.get_status_date (pp.policy_id,'UNDERWRITING') AS date_underrating, -- ���� ������� "������������"
       Doc.get_status_date (pp.policy_id,'ACTIVE') AS date_activate,-- ���� ������� "��������"
       f1.brief,-- ������ ���������������
       f2.brief, -- ������ ��������
       -- ������ ������
      Pkg_Agent_1.get_agent_status_name_by_date(agch.ag_contract_header_id,SYSDATE) AS agent_status,
       -- ������ ������������ ������ (��������� �����)
       Pkg_Agent_1.get_agent_status_name_by_date(agchLead.ag_contract_header_id,SYSDATE) AS agLead_status,
       Pkg_Agent_Rate.get_rate_oab (ppac.p_policy_agent_com_id) AS kv, -- ������ �������� ������
       Pkg_Agent_Rate.get_rate_oab (ppacLead.p_policy_agent_com_id) AS kvLead -- ������ �������� ������������ ������
   FROM ven_p_pol_header ph
   join ven_p_policy pp ON pp.policy_id = ph.policy_id
   --*/
   join ven_t_product pr ON pr.product_id = ph.product_id
   join ven_fund f1 ON f1.fund_id = ph.fund_id
   join ven_fund f2 ON f2.fund_id = ph.fund_pay_id
   --/*
   -- �������� ����� �������� (���������)
   left join ven_as_asset ass ON ass.p_policy_id = pp.policy_id
   left join ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   left join ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
   left join ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
   -- */
   --/*
   -- �������� ��� ���������
   left join ven_t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join ven_t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
   --*/
  -- /*
   -- �������� ��������� ���������
   join ven_t_payment_terms tpt ON tpt.id = pp.payment_term_id
   join v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id
   join ven_ac_payment ap ON ap.payment_id = sch.document_id
   left join doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   left join ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   --*/
   --/*
  -- ������
   left join ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   left join ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
   left join ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   left join ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   left join ven_ag_category_agent agCatAg ON agCatAg.ag_category_agent_id = agc.category_id
   left join ven_p_policy_agent ppagLead ON ppagLead.ag_contract_header_id = agchLead.ag_contract_header_id
   left join ven_p_policy_agent_com ppac ON ppac.p_policy_agent_id = ppag.p_policy_agent_id AND ppac.t_product_line_id = tPrLn.id
   left join ven_p_policy_agent_com ppacLead ON ppacLead.p_policy_agent_id = ppagLead.p_policy_agent_id AND ppac.t_product_line_id = tPrLn.id
    left join ven_policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id
   --*/
   --/*
   -- �������� (��� ������)
   left join ven_contact c ON c.contact_id = agch.agent_id
   left join ven_t_contact_type tct ON tct.id = c.contact_type_id
   --*/
   WHERE  NVL(pAgSt.brief,'CURRENT') = 'CURRENT'
ORDER BY pp.policy_id
  --call ents_bi.grant_to_eul('ALL')
;

