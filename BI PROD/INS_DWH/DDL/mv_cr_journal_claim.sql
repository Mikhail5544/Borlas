CREATE MATERIALIZED VIEW INS_DWH.MV_CR_JOURNAL_CLAIM
BUILD DEFERRED
REFRESH FORCE ON DEMAND
AS
SELECT pp.policy_id, -- id договора
     cc.c_claim_id, -- id дела
     ins.pkg_claim.get_prev_claim_num(cc.c_claim_id) AS prev_num,-- номер предыдущего дела
     cc.num AS claim_num, -- номер дела
     pp.num AS pol_num,-- номер полиса
     -- TODO:тип полиса (индивидуальный, корпоративный, кредитный)
     pr.description AS product,--  продукт
     pl.brief AS programm, -- сокращение программы
     -- TODO: застрахованный (в отчете)
     ins.ent.obj_name('CONTACT',agch.agent_id) AS agent,-- фио агента
     ins.ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- фио руководителя агента
     d.name AS agency,-- агенство
     ph.start_date,  --  дата начала действия договора
     ce.date_company, -- дата получения уведомления
     ins.doc.get_status_date(cc.c_claim_id,'DOC_ALL')AS st_date_alldoc,  -- дата последнего статуса по делу "Все документы"
     ce.event_date, -- дата СС
     -- TODO: количество дней действия полиса до наступления СС (в отчете)
     ce.diagnose, -- диагноз
     ins.pkg_claim.get_damage_risk_list (cc.c_claim_id) AS risk_list, -- список рисков
     ins.pkg_claim.get_lim_amount (cd.t_damage_code_id,cd.p_cover_id) AS lim_amount, -- лимит ответственности  по рискам
     ins.pkg_claim.get_percent_sum(cc.c_claim_id) AS percent_sum, -- процент от СС суммы по всем страховым убыткам
     ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id) AS payment_sum,-- сумма к выплате
     ins.doc.get_status_date(cc.c_claim_id,'REGULATE')AS st_date_ureg, -- дата статуса урегулируется
     ins.doc.get_status_date(cc.c_claim_id,'CLOSE')AS st_date_close, --  дата статуса закрыт
     ins.pkg_claim_payment.get_first_entry_date(cc.c_claim_id) AS first_entry_date, -- дата первой проводки
     ch.deductible_value, -- сумма франшизы по всем убыткам
     ins.pkg_claim_payment.get_claim_pay_sum (cc.c_claim_id) AS pay_summ_claim,-- сумма выплаченного страхового обеспечения по делу
     -- TODO: процент перестраховщика (в отчете)
     rc.part_sum, -- доля перестраховщика
     -- TODO: сумма выплаченного страхового обеспечения по риску
     ccs.description AS curr_st,-- текущий статус дела
     ins.pkg_rep_utils.get_med_expert(cc.c_claim_id) AS med_expert, -- наличие мед экспертизыg
     ins.pkg_rep_utils.get_claim_sb_request_date(ch.c_claim_header_id) AS req_date, -- дата запроса СБ
          ins.pkg_rep_utils.get_claim_sb_receipt_date(ch.c_claim_header_id) AS reс_date, -- дата получения СБ
     -- TODO: срок перечисления (в отчете)
     ins.doc.get_status_date (cc.c_claim_id,'ACTIVE') AS st_date_active,-- дата перевода в статус активный
     ins.pkg_claim_payment.get_first_account_date(cc.c_claim_id) AS account_date-- дата выставления первого распоряжения
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
   -- агенты
     left join ins.ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id --
     left join ins.ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
     left join ins.ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
     left join ins.ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
     left join ins.ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
     left join ins.ven_department d ON d.department_id = agch.agency_id
     WHERE (ppag.status_id = (SELECT pAgSt.policy_agent_status_id FROM ins.ven_policy_agent_status pAgSt WHERE pAgSt.brief = 'CURRENT')
     OR ppag.p_policy_agent_id IS NULL);

