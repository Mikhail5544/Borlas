CREATE MATERIALIZED VIEW INS_DWH.MV_CR_BALANCE_CLIENT
BUILD DEFERRED
REFRESH FORCE ON DEMAND
AS
SELECT pp.policy_id, -- ИД полиса
       pp.num AS pol_num,-- номер договора
       pp.notice_num,-- номер заявления
       ins.doc.get_doc_status_name(pp.policy_id) AS pol_status,-- статус договора на момент выгрузки
       pr.description AS product,-- продукт
       ins.pkg_rep_utils.get_programm_list (pp.policy_id) AS programm_list, --  список программ
       ph.start_date,--  начало периода действия договора
       pp.end_date,-- окончание периода действия договора
       tpt.description AS period,-- периодичность
       ins.pkg_rep_utils.get_min_date(pp.policy_id) AS due_date,-- дата ближайшей премии
       ins.pkg_rep_utils.get_amount_for_date (pp.policy_id,  ins.pkg_rep_utils.get_min_date(pp.policy_id)) AS part_amount, -- сумма премии
       q1.col_payed_amount,
       q2.col_unpayed_amount,
       ins.pkg_policy_cash_surrender.Get_Value_C(q3.p_cover_id,SYSDATE) AS redemption_sum,
       ins.pkg_policy_cash_surrender.Get_Value_C(q4.p_cover_id,SYSDATE) AS ivest_sum,
       ins.pkg_claim_payment.get_close_claim_summ (pp.policy_id) AS close_claim,-- оплаченные убытки по договору
       ins.pkg_claim_payment.get_un_close_claim_sum(pp.policy_id) AS unclose_claim,-- заявленные ,но не урегулированные убытки
       pp.decline_summ, -- выплаты при расторжении договора
       ins.ent.obj_name('CONTACT',agch.agent_id) AS agent,-- фио агента
       ins.ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- фио руководителя агента
       d.name AS agency,-- агенство
       f1.brief AS fund,-- валюта ответственности
       f2.brief AS fund_pay -- валюта расчетов
FROM ins.ven_p_pol_header ph
     join ins.ven_p_policy pp ON pp.policy_id = ph.policy_id
   join ins.ven_t_product pr ON pr.product_id = ph.product_id
   join ins.ven_fund f1 ON f1.fund_id = ph.fund_id
   join ins.ven_fund f2 ON f2.fund_id = ph.fund_pay_id
   join ins.ven_t_payment_terms tpt ON tpt.id = pp.payment_term_id
     join ins.ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
     left join ins.ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
     left join ins.ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
     left join ins.ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
     left join ins.ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
     left join ins.ven_department d ON d.department_id = agch.agency_id
     left join (SELECT COUNT(dof.doc_set_off_id) col_payed_amount, sch.policy_id
       FROM ins.v_policy_payment_schedule sch
       left join ins.ven_ac_payment ap ON ap.payment_id = sch.document_id
       left join ins.ven_doc_set_off dof ON dof.parent_doc_id = ap.payment_id
       WHERE dof.set_off_amount >= sch.part_amount AND ap.due_date <= SYSDATE
       group by sch.policy_id) q1 on q1.policy_id = pp.policy_id
     left join (SELECT COUNT(dof.doc_set_off_id) col_unpayed_amount, sch.policy_id
       FROM ins.v_policy_payment_schedule sch
       left join ins.ven_ac_payment ap ON ap.payment_id = sch.document_id
       left join ins.ven_doc_set_off dof ON dof.parent_doc_id = ap.payment_id
       WHERE (dof.doc_set_off_id IS NULL OR dof.set_off_amount < sch.part_amount)
       AND ap.due_date < SYSDATE
       GROUP BY sch.policy_id
       ) q2 ON q2.policy_id <= pp.policy_id
     left join (SELECT pCov.p_cover_id, ass.p_policy_id, row_number() over(partition by ass.p_policy_id order by pCov.p_cover_id) rn
        FROM ins.ven_as_asset ass
        join ins.ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
        join ins.ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
        join ins.ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
        join ins.ven_t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
        WHERE tPrLnT.brief = 'RECOMMENDED') q3 on pp.policy_id = q3.p_policy_id and q3.rn = 1
     left join (SELECT pCov.p_cover_id, ass.p_policy_id, row_number() over(partition by ass.p_policy_id order by pCov.p_cover_id) rn
        FROM ins.ven_as_asset ass
        join ins.ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
        join ins.ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
        join ins.ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
        join ins.ven_t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
        WHERE tLobLn.brief = 'I2') q4 on pp.policy_id = q4.p_policy_id and q4.rn = 1
WHERE (ppag.status_id = (SELECT pAgSt.policy_agent_status_id FROM ins.ven_policy_agent_status pAgSt WHERE pAgSt.brief = 'CURRENT') OR ppag.p_policy_agent_id IS NULL);

