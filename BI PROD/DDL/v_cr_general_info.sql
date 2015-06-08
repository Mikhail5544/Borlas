CREATE OR REPLACE FORCE VIEW V_CR_GENERAL_INFO AS
SELECT /*+ FIRST_ROWS */ pp.policy_id, -- ИД полиса
       pp.pol_ser as policy_ser,
       pp.pol_num AS policy_num,-- номер договора
       pp.notice_num,-- номер заявления
       pr.description AS product,-- продукт
       tLob.brief AS product_kode,-- код программы
       tPrLn.description AS main_programm, -- основная программа в продукте
       ph.start_date, -- дата начала действия договора
       pp.end_date, -- дата окончания действия
       -- срок действия договора в годах
       CEIL(MONTHS_BETWEEN(pp.end_date,ph.start_date)/12) AS act_period,
       pp.notice_date, -- дата регистрации заявления в системе
       pp.ins_amount, -- лимит ответственности по договору
       pp.fee_payment_term,-- период уплаты (в годах)
       Pkg_Rep_Utils.get_admin_expenses (pp.policy_id)
        * ins.acc_new.Get_Cross_Rate_By_Id(
                                1,
                                ph.fund_id,
                                122,
                                ph.start_date
                                ) AS admin_expenses, -- административные издержки
       (pp.premium - Pkg_Rep_Utils.get_admin_expenses (pp.policy_id)) AS pol_premium, -- размер премии по договору
       pCov.premium,-- премия по основной программе
       pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(
                                1,
                                ph.fund_id,
                                122,
                                ph.start_date
                                ) AS premium_year,-- годовая премия
       tpt.description AS period,-- периодичность
       Pkg_Rep_Utils.get_period_code (tpt.description) AS period_code,-- код периодичности
       -- TODO: размер пенсии / ренты (пока не можем сделать)
       -- TODO: периодичность выплаты пенсии / ренты (пока не можем сделать)
       -- TODO: Дата начала выплаты пенсии / ренты (пока не можем сделать)
       -- оплаченная премия по договору
       Pkg_Payment.get_pay_pol_header_amount_pfa(ph.start_date,SYSDATE,ph.policy_header_id) AS pay_premium,
       ap.due_date, -- плановая дата платежа
       --sch.part_amount, -- плановая сумма платежа
       ddsch.parent_amount part_amount,
       ap.payment_number,-- id планового платежа
       ap1.due_date AS doc_pay_date,-- дата документа зачета
       ap1.doc_templ_id AS doc_pay_tipe, -- id типа документа зачета
       ap1.num AS doc_pay_num, -- номер документа зачета
       dof.set_off_amount, -- сумма зачета
       Ent.obj_name('CONTACT',agch.agent_id) AS agent,-- фио агента
       sch.description as sales_channel,
       dagch.num AS ag_num, -- номер агентского договора
       Ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- фио руководителя агента
       Ent.obj_name('CONTACT',agchRecr.agent_id) AS agent_recruter, -- рекрутер
       d.name AS agency, -- агенство
       Doc.get_doc_status_name(pp.policy_id) AS doc_status,-- статус договора на момент выгрузки
        --/*
        -- дата последнего статуса
       (SELECT MAX(ds.start_date)
        FROM doc_status ds,doc_status_ref dsr
        WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
           AND dsr.brief =  Doc.get_doc_status_brief(pp.policy_id)
           AND ds.document_id = pp.policy_id) AS date_status,
        --*/
      Doc.get_status_date(pp.policy_id,'PRINTED') AS date_printed,
      --/*
      -- куратор договора
        Ent.obj_name('CONTACT',
        (SELECT ppc.contact_id FROM ven_p_policy_contact ppc, ven_t_contact_pol_role pr
        WHERE pr.id = ppc.contact_policy_role_id
        AND pr.brief = 'Куратор'
        AND ppc.policy_id = pp.policy_id
        AND ROWNUM = 1)
        ) AS curator ,
        --*/
         --/*
      -- региональный менеджер
        Ent.obj_name('CONTACT',
        (SELECT ppc.contact_id FROM ven_p_policy_contact ppc, ven_t_contact_pol_role pr
        WHERE pr.id = ppc.contact_policy_role_id
        AND pr.brief = 'РегМенеджер'
        AND ppc.policy_id = pp.policy_id
        AND ROWNUM = 1)
        ) AS reg_meneger ,
        --*/
       --  дата окончания выжидательного периода
       Pkg_Policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,ph.start_date) AS wait_period,
       f1.brief AS fund,-- валюта ответственности
       f2.brief AS fund_pay-- валюта расчетов
   FROM p_policy pp
    join p_pol_header ph ON pp.policy_id = ph.policy_id
   left join t_period tPer ON tPer.id = pp.waiting_period_id
  --/*
   --агенты
   left join p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   left join document dagch on dagch.document_id = ppag.ag_contract_header_id
   left join ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
   left join t_sales_channel sch on (sch.id = ph.sales_channel_id)
   --left join t_sales_channel sch on (sch.id = agch.t_sales_channel_id)
   left join department d ON d.department_id = agch.agency_id
   left join ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   left join ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   left join ag_contract agRecr ON agRecr.ag_contract_id = agc.contract_recrut_id
   left join ag_contract_header agchRecr ON agchRecr.ag_contract_header_id = agRecr.contract_id
   left join ag_category_agent agCatAg ON agCatAg.ag_category_agent_id = agc.category_id
   left join policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id
   --*/
   join t_product pr ON pr.product_id = ph.product_id
   join fund f1 ON f1.fund_id = ph.fund_id
   join fund f2 ON f2.fund_id = ph.fund_pay_id
   --/*
   -- получаем линию продукта (программу)
   left join as_asset ass ON ass.p_policy_id = pp.policy_id
   left join p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   left join t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
   left join t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
   left join t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
  -- */
   --/*
    --получаем код программы
   left join t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
   --*/
   --/*
    --получаем платежные документы
   left join t_payment_terms tpt ON tpt.id = pp.payment_term_id
   --
  -- left join v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id
  left join doc_doc ddsch on ddsch.parent_id = pp.policy_id
   left join ac_payment ap ON ap.payment_id = ddsch.child_id --sch.document_id
   --
   left join doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   left join ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   --*/
WHERE NVL(tPrLnT.brief,'RECOMMENDED') = 'RECOMMENDED'
   AND (NVL(pAgSt.brief,'CURRENT') = 'CURRENT' or pAgSt.brief = 'NEW')
   --and pp.policy_id = 6765794
;

