create or replace force view v_cr_policy_condition as
select pp.policy_id, -- �� ������
      --/*
       pp.num as pol_num,-- ����� ��������
       pp.notice_num,-- ����� ���������
       doc.get_doc_status_name(pp.policy_id) as pol_status,-- ������ �������� �� ������ ��������
       pr.description as product,-- �������
       tPrLn.description as programm, --  ������ ��������
       ph.start_date,--  ������ ������� �������� ��������
       pp.end_date,-- ��������� ������� �������� ��������
       tpt.description as period,-- �������������
       sch.due_date,-- �������� ���� �������
       sch.part_amount, -- ����� ������
       -- TODO: ������ ��������� �� �������� (���� �� ����� �������)
       -- TODO: ������ ��������� �� �������� (���� �� ����� �������)
       -- TODO: ������ �� �������� (���� �� ����� �������)
       --/*
       --/*
       -- ���������� ���������� �������� �� ��������
       (select count(dof.doc_set_off_id)
       from v_policy_payment_schedule sch
       left join ven_ac_payment ap on ap.payment_id = sch.document_id
       left join ven_doc_set_off dof on dof.parent_doc_id = ap.payment_id
       where dof.set_off_amount >= sch.part_amount
       and sch.policy_id = pp.policy_id
       and ap.due_date <= sysdate
       ) as col_payed_amount,
      -- */
      -- /*
       -- ���������� ��������� ������������ ��������
       (select count(dof.doc_set_off_id)
       from v_policy_payment_schedule sch
       left join ven_ac_payment ap on ap.payment_id = sch.document_id
       left join ven_doc_set_off dof on dof.parent_doc_id = ap.payment_id
       where (dof.doc_set_off_id is null or dof.set_off_amount < sch.part_amount)
       and ap.due_date < sysdate
       and sch.policy_id <= pp.policy_id
       ) as col_unpayed_amount,
       --*/
       --  ������ �������� ����� �� �������� ���������
       pkg_policy_cash_surrender.Get_Value_C(
       (select pCov.p_cover_id
        from ven_as_asset ass
        join ven_p_cover pCov on pCov.as_asset_id = ass.as_asset_id
        join ven_t_prod_line_option tPrLnOp on tPrLnOp.id = pCov.t_prod_line_option_id
        join ven_t_product_line tPrLn on tPrLn.id = tPrLnOp.product_line_id
        join ven_t_product_line_type tPrLnT on tPrLnT.product_line_type_id = tPrLn.product_line_type_id
        where tPrLnT.brief = 'RECOMMENDED'
        and ass.p_policy_id = pp.policy_id
        and rownum = 1)
       ,sysdate) as redemption_sum,
       --*/
       --*/
       --  ������ �������� ����� �� ��������� ������
       pkg_policy_cash_surrender.Get_Value_C(
       (select pCov.p_cover_id
        from ven_as_asset ass
        join ven_p_cover pCov on pCov.as_asset_id = ass.as_asset_id
        join ven_t_prod_line_option tPrLnOp on tPrLnOp.id = pCov.t_prod_line_option_id
        join ven_t_product_line tPrLn on tPrLn.id = tPrLnOp.product_line_id
        join ven_t_lob_line tLobLn on tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
        where tLobLn.brief = 'I2'
        and ass.p_policy_id = pp.policy_id
        and rownum = 1)
       ,sysdate) as ivest_sum,
       --*/
        --*/
       -- TODO : ����������
       -- TODO : ����������
       pkg_claim_payment.get_close_claim_summ (pp.policy_id) as close_claim,-- ���������� ������ �� ��������
       pkg_claim_payment.get_un_close_claim_sum(pp.policy_id) as unclose_claim,-- ���������� ,�� �� ��������������� ������
       pp.decline_summ, -- ������� ��� ����������� ��������
       --/*
       ent.obj_name('CONTACT',agch.agent_id) as agent,-- ��� ������
       ent.obj_name('CONTACT',agchLead.agent_id) as agent_lead ,-- ��� ������������ ������
       d.name as agency,-- ��������
       f1.brief as fund,-- ������ ���������������
       f2.brief as fund_pay, -- ������ ��������
        -- ������ ��
       pkg_agent_rate.get_rate_oab (ppac.p_policy_agent_com_id) as kv,
      --/*
       -- ����� ��������, ����������� ������
      (select sum(agrc.comission_sum)
       from agent_report agr
       join agent_report_cont agrc on agrc.agent_report_id = agr.agent_report_id
       where agr.ag_contract_h_id = agch.ag_contract_header_id
       group by agch.ag_contract_header_id) as comission,
       --*/
       ins_dwh.pkg_rep_utils_ins11.get_month_agent_dav(pp.policy_id) as month_dav, -- ����� ������� � ������� ���
       pkg_payment.get_pay_pol_header_amount_pfa(ph.start_date,sysdate,ph.policy_header_id) as pay_amount,-- ��������� ������ �� ��������
       pkg_payment.get_underpayment_amount (ph.policy_header_id) as under_pay_amount,-- ������ ��������� �� ��������
       pp.decline_date,-- ���� ����������� ��������
       pkg_rep_utils.get_decl_pay_date(ph.policy_header_id) as decl_pay_date-- ���� ������� �� ��������
       --*/
       --*/
from ven_p_pol_header ph
     join ven_p_policy pp on pp.policy_id = ph.policy_id
     -- /*
   join ven_t_product pr on pr.product_id = ph.product_id
   join ven_fund f1 on f1.fund_id = ph.fund_id
   join ven_fund f2 on f2.fund_id = ph.fund_pay_id
   --*/
   --/*
   -- �������� ����� �������� (���������)
   join ven_as_asset ass on ass.p_policy_id = pp.policy_id
   join ven_p_cover pCov on pCov.as_asset_id = ass.as_asset_id
   join ven_t_prod_line_option tPrLnOp on tPrLnOp.id = pCov.t_prod_line_option_id
   join ven_t_product_line tPrLn on tPrLn.id = tPrLnOp.product_line_id
   -- */
   --/*
   -- �������� ��� ���������
   left join ven_t_lob_line tLobLn on tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join ven_t_lob tLob on tLob.t_lob_id = tLobLn.t_lob_id
   --*/
   --/*
   -- �������� ��������� ���������
   join ven_t_payment_terms tpt on tpt.id = pp.payment_term_id
   join v_policy_payment_schedule sch on sch.policy_id = pp.policy_id
   --*/
  --/*
  -- ������
     join ven_p_policy_agent ppag on ppag.policy_header_id = ph.policy_header_id
     left join ven_ag_contract_header agch on agch.ag_contract_header_id = ppag.ag_contract_header_id
     left join ven_ag_contract agc on agch.last_ver_id = agc.ag_contract_id
     left join ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
     left join ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
     left join ven_department d on d.department_id = agch.agency_id
     left join ven_p_policy_agent_com ppac on ppac.p_policy_agent_id = ppag.p_policy_agent_id and ppac.t_product_line_id = tPrLn.id
     left join ven_policy_agent_status pAgSt on pAgSt.policy_agent_status_id = ppag.status_id
   --*/
 where  nvl(pAgSt.brief,'CURRENT') = 'CURRENT'
order by pp.policy_id
;

