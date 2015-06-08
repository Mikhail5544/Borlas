CREATE OR REPLACE FORCE VIEW V_CR_BALANCE_CLIENT AS
SELECT pp.policy_id, -- ИД полиса
      --/*
       pp.num AS pol_num,-- номер договора
       pp.notice_num,-- номер заявления
       doc.get_doc_status_name(pp.policy_id) AS pol_status,-- статус договора на момент выгрузки
       pr.description AS product,-- продукт
       pkg_rep_utils.get_programm_list (pp.policy_id) AS programm_list, --  список программ
       ph.start_date,--  начало периода действия договора
       pp.end_date,-- окончание периода действия договора
       tpt.description AS period,-- периодичность
       pkg_rep_utils.get_min_date(pp.policy_id) AS due_date,-- дата ближайшей премии
       pkg_rep_utils.get_amount_for_date (pp.policy_id,  pkg_rep_utils.get_min_date(pp.policy_id)) AS part_amount, -- сумма премии
       -- TODO: размер переплаты по договору (пока не можем сделать)
       -- TODO: размер недоплаты по договору (пока не можем сделать)
       -- TODO: сальдо по договору (пока не можем сделать)
       --/*
       -- количество оплаченных платежей по договору
       (SELECT COUNT(dof.doc_set_off_id)
       FROM v_policy_payment_schedule sch
       left join ven_ac_payment ap ON ap.payment_id = sch.document_id
       left join ven_doc_set_off dof ON dof.parent_doc_id = ap.payment_id
       WHERE dof.set_off_amount >= sch.part_amount
       AND sch.policy_id = pp.policy_id
       AND ap.due_date <= SYSDATE
       ) AS col_payed_amount,
      -- */
      -- /*
       -- количество полностью просроченных платежей
       (SELECT COUNT(dof.doc_set_off_id)
       FROM v_policy_payment_schedule sch
       left join ven_ac_payment ap ON ap.payment_id = sch.document_id
       left join ven_doc_set_off dof ON dof.parent_doc_id = ap.payment_id
       WHERE (dof.doc_set_off_id IS NULL OR dof.set_off_amount < sch.part_amount)
       AND ap.due_date < SYSDATE
       AND sch.policy_id <= pp.policy_id
       ) AS col_unpayed_amount,
       --*/
       --  размер выкупной суммы по основной программе
       pkg_policy_cash_surrender.Get_Value_C(
       (SELECT pCov.p_cover_id
        FROM ven_as_asset ass
        join ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
        join ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
        join ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
        join ven_t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
        WHERE tPrLnT.brief = 'RECOMMENDED'
        AND ass.p_policy_id = pp.policy_id
        AND ROWNUM = 1)
       ,SYSDATE) AS redemption_sum,
       --*/
       --*/
       --  размер выкупной суммы по программе Инвест
       pkg_policy_cash_surrender.Get_Value_C(
       (SELECT pCov.p_cover_id
        FROM ven_as_asset ass
        join ven_p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
        join ven_t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
        join ven_t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
        join ven_t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
        WHERE tLobLn.brief = 'I2'
        AND ass.p_policy_id = pp.policy_id
        AND ROWNUM = 1)
       ,SYSDATE) AS ivest_sum,
       --*/
        --*/
       -- TODO : доходность
       -- TODO : индексация
       pkg_claim_payment.get_close_claim_summ (pp.policy_id) AS close_claim,-- оплаченные убытки по договору
       pkg_claim_payment.get_un_close_claim_sum(pp.policy_id) AS unclose_claim,-- заявленные ,но не урегулированные убытки
       pp.decline_summ, -- выплаты при расторжении договора
       --/*
       ent.obj_name('CONTACT',agch.agent_id) AS agent,-- фио агента
       ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- фио руководителя агента
       d.name AS agency,-- агенство
       f1.brief AS fund,-- валюта ответственности
       f2.brief AS fund_pay -- валюта расчетов
       --*/
FROM ven_p_pol_header ph
     join ven_p_policy pp ON pp.policy_id = ph.policy_id
     -- /*
   join ven_t_product pr ON pr.product_id = ph.product_id
   join ven_fund f1 ON f1.fund_id = ph.fund_id
   join ven_fund f2 ON f2.fund_id = ph.fund_pay_id
   --*/
   --/*
   -- получаем платежные документы
   join ven_t_payment_terms tpt ON tpt.id = pp.payment_term_id
   --*/
   --/*
   -- агенты
     join ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
     left join ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
     left join ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
     left join ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
     left join ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
     left join ven_department d ON d.department_id = agch.agency_id
  --*/
  WHERE (ppag.status_id = (SELECT pAgSt.policy_agent_status_id FROM ven_policy_agent_status pAgSt WHERE pAgSt.brief = 'CURRENT')
  OR ppag.p_policy_agent_id IS NULL)
ORDER BY pp.policy_id
;

