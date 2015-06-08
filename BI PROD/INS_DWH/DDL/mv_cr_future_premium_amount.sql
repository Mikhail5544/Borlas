CREATE MATERIALIZED VIEW INS_DWH.MV_CR_FUTURE_PREMIUM_AMOUNT
BUILD DEFERRED
REFRESH FORCE ON DEMAND
AS
SELECT pp.policy_id polisy_id,  -- �� ������
       sCH.Description canal,-- ����� ������
       d.name agency,-- ��������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num contract_num, -- ����� ��������
       ins.Ent.obj_name('CONTACT',agch.agent_id) agent,-- ��� ������
       ins.Ent.obj_name('CONTACT',agchLead.agent_id) agent_leader,-- ��� ������������ ������
       tpt.description period,-- �������������
       ap.payment_number,-- id ��������� �������
       sch.due_date,-- ���� ������ �� ������� ��������
       sch.part_amount premium,-- ����� ������
       ap1.due_date payment_date, -- ���� �������
       dof.set_off_amount payment, --����� �������
       tLob.brief programm_kode,-- ��� ���������
       tPrLn.description programm_name, -- �������� ��������� � ��������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� �������� ��������
       f.brief fund, -- ������ �� ��������
       pr.description product -- �������
FROM ins.ven_p_pol_header ph
     join ins.ven_p_policy pp ON pp.policy_id = ph.policy_id
     join ins.ven_t_product pr ON pr.product_id = ph.product_id
   -- ����� ������
   join ins.ven_t_sales_channel sCH ON sCH.Id = ph.sales_channel_id
  -- ������
   left join ins.ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   left join ins.ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ins.ven_ag_contract agc ON agc.ag_contract_id = agch.last_ver_id
   left join ins.ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   left join ins.ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   left join ins.ven_department d ON d.department_id = agch.agency_id
   left join ins.ven_policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id
   -- �������� ��������� ���������
   join ins.ven_t_payment_terms tpt ON tpt.id = pp.payment_term_id
   join ins.v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id
   join ins.ven_ac_payment ap ON ap.payment_id = sch.document_id
   join ins.ven_fund f ON f.fund_id = ap.fund_id
   left join ins.doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   left join ins.ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   -- �������� ����� �������� (���������)
   left join ins.ven_as_asset ass ON ass.p_policy_id = pp.policy_id
   left join ins.ven_as_assured assur ON assur.as_assured_id = ass.as_asset_id
   left join ins.ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   left join ins.ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
   left join ins.ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
   left join ins.ven_t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
    --�������� ��� ���������
   left join ins.ven_t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join ins.ven_t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
WHERE NVL(tPrLnT.brief,'RECOMMENDED') = 'RECOMMENDED'
   AND NVL(pAgSt.brief,'CURRENT') = 'CURRENT';

