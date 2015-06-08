CREATE MATERIALIZED VIEW INS_DWH.MV_CR_JOURNAL_CLAIM
BUILD DEFERRED
REFRESH FORCE ON DEMAND
AS
SELECT pp.policy_id, -- id ��������
     cc.c_claim_id, -- id ����
     ins.pkg_claim.get_prev_claim_num(cc.c_claim_id) AS prev_num,-- ����� ����������� ����
     cc.num AS claim_num, -- ����� ����
     pp.num AS pol_num,-- ����� ������
     -- TODO:��� ������ (��������������, �������������, ���������)
     pr.description AS product,--  �������
     pl.brief AS programm, -- ���������� ���������
     -- TODO: �������������� (� ������)
     ins.ent.obj_name('CONTACT',agch.agent_id) AS agent,-- ��� ������
     ins.ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- ��� ������������ ������
     d.name AS agency,-- ��������
     ph.start_date,  --  ���� ������ �������� ��������
     ce.date_company, -- ���� ��������� �����������
     ins.doc.get_status_date(cc.c_claim_id,'DOC_ALL')AS st_date_alldoc,  -- ���� ���������� ������� �� ���� "��� ���������"
     ce.event_date, -- ���� ��
     -- TODO: ���������� ���� �������� ������ �� ����������� �� (� ������)
     ce.diagnose, -- �������
     ins.pkg_claim.get_damage_risk_list (cc.c_claim_id) AS risk_list, -- ������ ������
     ins.pkg_claim.get_lim_amount (cd.t_damage_code_id,cd.p_cover_id) AS lim_amount, -- ����� ���������������  �� ������
     ins.pkg_claim.get_percent_sum(cc.c_claim_id) AS percent_sum, -- ������� �� �� ����� �� ���� ��������� �������
     ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id) AS payment_sum,-- ����� � �������
     ins.doc.get_status_date(cc.c_claim_id,'REGULATE')AS st_date_ureg, -- ���� ������� �������������
     ins.doc.get_status_date(cc.c_claim_id,'CLOSE')AS st_date_close, --  ���� ������� ������
     ins.pkg_claim_payment.get_first_entry_date(cc.c_claim_id) AS first_entry_date, -- ���� ������ ��������
     ch.deductible_value, -- ����� �������� �� ���� �������
     ins.pkg_claim_payment.get_claim_pay_sum (cc.c_claim_id) AS pay_summ_claim,-- ����� ������������ ���������� ����������� �� ����
     -- TODO: ������� ��������������� (� ������)
     rc.part_sum, -- ���� ���������������
     -- TODO: ����� ������������ ���������� ����������� �� �����
     ccs.description AS curr_st,-- ������� ������ ����
     ins.pkg_rep_utils.get_med_expert(cc.c_claim_id) AS med_expert, -- ������� ��� ����������g
     ins.pkg_rep_utils.get_claim_sb_request_date(ch.c_claim_header_id) AS req_date, -- ���� ������� ��
          ins.pkg_rep_utils.get_claim_sb_receipt_date(ch.c_claim_header_id) AS re�_date, -- ���� ��������� ��
     -- TODO: ���� ������������ (� ������)
     ins.doc.get_status_date (cc.c_claim_id,'ACTIVE') AS st_date_active,-- ���� �������� � ������ ��������
     ins.pkg_claim_payment.get_first_account_date(cc.c_claim_id) AS account_date-- ���� ����������� ������� ������������
FROM ins.ven_c_claim_header ch
join ins.ven_c_claim cc ON ch.active_claim_id = cc.c_claim_id
join ins.ven_p_policy pp ON pp.policy_id = ch.p_policy_id
join ins.ven_p_pol_header ph ON ph.policy_header_id = pp.pol_header_id
join ins.ven_t_product pr ON pr.product_id = ph.product_id
join ins.ven_c_event ce ON ce.c_event_id = ch.c_event_id --
left join ins.ven_c_claim_status ccs ON ccs.c_claim_status_id = cc.claim_status_id
left join ins.ven_c_damage cd ON cd.c_claim_id = cc.c_claim_id
left join ins.ven_p_cover pc ON pc.p_cover_id = ch.p_cover_id
left join ins.ven_t_prod_line_option plo ON plo.id = pc.t_prod_line_option_id
left join ins.ven_t_product_line pl ON pl.id = plo.product_line_id
left join ins.ven_re_cover rc ON rc.p_cover_id = pc.p_cover_id
   -- ������
     left join ins.ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id --
     left join ins.ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
     left join ins.ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
     left join ins.ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
     left join ins.ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
     left join ins.ven_department d ON d.department_id = agch.agency_id
     WHERE (ppag.status_id = (SELECT pAgSt.policy_agent_status_id FROM ins.ven_policy_agent_status pAgSt WHERE pAgSt.brief = 'CURRENT')
     OR ppag.p_policy_agent_id IS NULL);

