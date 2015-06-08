CREATE OR REPLACE FORCE VIEW V_CR_FUTURE_PREMIUM_AMOUNT
(polisy_id, canal, agency, pol_ser, pol_num, contract_num, agent, agent_leader, period, payment_number, due_date, premium, payment_date, payment, programm_kode, programm_name, start_date, end_date, fund, product, indexing_fee)
AS
SELECT pp.policy_id,  -- �� ������
       sCH.Description,-- ����� ������
       d.name,-- ��������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num, -- ����� ��������
       Ent.obj_name('CONTACT',agch.agent_id) AS agent,-- ��� ������
       Ent.obj_name('CONTACT',agchLead.agent_id)AS agent_lead,-- ��� ������������ ������
       tpt.description,-- �������������
       ap.payment_number,-- id ��������� �������
       sch.due_date,-- ���� ������ �� ������� ��������
       sch.part_amount,-- ����� ������
       ap1.due_date, -- ���� �������
       dof.set_off_amount, --����� �������
       tLob.brief AS product_kode,-- ��� ���������
       tPrLn.description AS main_programm, -- �������� ��������� � ��������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� �������� ��������
       f.brief, -- ������ �� ��������
       pr.description, -- �������
       (select sum(pc.fee) --��������� ���� ��������� �������������
          from p_policy     p2,
               as_asset     aa,
               status_hist  sha,
               p_cover      pc,
               status_hist  shp
         where 1=1
           and p2.pol_header_id = ph.policy_header_id
           and p2.version_num = (select max(p3.version_num)
                                   from p_policy p3
                                  where p3.pol_header_id = p2.pol_header_id
                                    and doc.get_doc_status_brief(p3.policy_id) = 'INDEXATING'
                                )
           and aa.p_policy_id = p2.policy_id
           and sha.status_hist_id = aa.status_hist_id
           and sha.brief <> 'DELETED'
           and pc.as_asset_id = aa.as_asset_id
           and shp.status_hist_id = pc.status_hist_id
           and shp.brief <> 'DELETED'
           AND pc.t_prod_line_option_id = pCov.t_prod_line_option_id
       )"��������������� ������-�����"
FROM ven_p_pol_header ph
     join ven_p_policy pp ON pp.policy_id = ph.policy_id
     join ven_t_product pr ON pr.product_id = ph.product_id
   --/*
   -- ����� ������
   join ven_t_sales_channel sCH ON sCH.Id = ph.sales_channel_id
   --*/
  --/*
  -- ������
   left join ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   left join ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ven_ag_contract agc ON agc.ag_contract_id = agch.last_ver_id
   left join ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   left join ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   left join ven_department d ON d.department_id = agch.agency_id
   left join ven_policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id
   -- */
   --/*
   -- �������� ��������� ���������
   join ven_t_payment_terms tpt ON tpt.id = pp.payment_term_id
   join v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id
   join ven_ac_payment ap ON ap.payment_id = sch.document_id
   join ven_fund f ON f.fund_id = ap.fund_id
   left join doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   left join ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   --*/
    --/*
   -- �������� ����� �������� (���������)
   left join ven_as_asset ass ON ass.p_policy_id = pp.policy_id
   left join ven_as_assured assur ON assur.as_assured_id = ass.as_asset_id
   left join ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   left join ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
   left join ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
   left join ven_t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
   -- */
   --/*
    --�������� ��� ���������
   left join ven_t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join ven_t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
   --*/
WHERE NVL(tPrLnT.brief,'RECOMMENDED') = 'RECOMMENDED'
   AND NVL(pAgSt.brief,'CURRENT') = 'CURRENT'
   and pkg_policy.get_last_version_status(ph.policy_header_id) not in ('��������� � �����������','����������')
   --and sch.due_date between to_date('20-01-2009','dd-mm-yyyy') and to_date('31-01-2009','dd-mm-yyyy')
   --and ph.policy_header_id = 809179
ORDER BY pp.policy_id
;

