CREATE OR REPLACE VIEW V_PRESENT_LIFE AS
SELECT /* leading(phid)*/
 phid.description "Продукт"
 ,c.obj_name_orig "Страхователь"
 ,CASE
   WHEN EXISTS (SELECT 1
           FROM ins.cn_contact_ident ci
               ,ins.t_id_type        cit
          WHERE 1 = 1
            AND ci.contact_id = c.contact_id
            AND ci.id_type = cit.id
            AND (ci.termination_date IS NULL OR ci.termination_date > trunc(SYSDATE))
            AND cit.brief = 'PRESENT_LIFE'
            AND ((ci.id_value = phid.pol_num) OR
                (ci.id_value = substr(phid.pol_ser || phid.pol_num, 4, 6)) OR
                (ci.id_value = substr(phid.pol_ser || phid.pol_num, 1, 9)))) THEN
    'Да'
   ELSE
    'Нет'
 END "Передача в Фонд"
 ,phid.pol_num "Номер договора"
 ,(SELECT dsr.name FROM ins.doc_status_ref dsr WHERE d.doc_status_ref_id = dsr.doc_status_ref_id) "Статус полиса"
 ,CASE
   WHEN phid.first_pay_date = ap.plan_date THEN
    'Да'
   ELSE
    'Нет'
 END "1-й ЭПГ"
 ,trunc(MONTHS_BETWEEN(trunc(phid.end_date) + 1, trunc(phid.start_date)) / 12, 2) "Срок, лет"
 ,(SELECT pt.description FROM ins.t_payment_terms pt WHERE phid.payment_term_id = pt.id) "Периодичность оплаты"
 ,(SELECT cm.description FROM ins.t_collection_method cm WHERE phid.collection_method_id = cm.id) "Тип расчетов"
 ,phid.start_date "Дата начала"
 ,trunc(phid.end_date) "Дата окончания"
 ,(SELECT trunc(start_date) FROM ins.doc_status WHERE doc_status_id = dap.doc_status_id) "Дата платежа"
 ,ap.plan_date "Дата графика"
 ,phid.fee "Брутто-взнос"
 ,(SELECT f.brief FROM ins.fund f WHERE phid.fund_pay_id = f.fund_id) "Валюта"
 ,t.trans_amount "Сумма проводки"
 ,t.trans_date "Дата проводки"
  FROM ins.document d
      ,ins.doc_status ds
      ,(SELECT /*+ no_merge use_nl(plo,pc,ass,ppp, pph)*/
         pph.policy_header_id
        ,pc.fee
        ,plo.id
        ,ppl.product_name description
        ,pph.fund_pay_id
        ,pph.policy_id
        ,pph.start_date
        ,ppp.pol_ser
        ,ppp.pol_num
        ,ppp.first_pay_date
        ,ppp.end_date
        ,ppp.payment_term_id
        ,ppp.collection_method_id
          FROM ins.p_pol_header pph
              ,ins.p_policy     ppp
               --      ,ins.t_product    p
               /**/
              ,ins.as_asset            ass
              ,ins.p_cover             pc
              ,ins.t_prod_line_option  plo
              ,ins.v_prod_product_line ppl
         WHERE 1 = 1
              --AND pph.product_id = p.product_id
           AND ppl.product_brief IN ('END'
                                    ,'END_2'
                                    , -- Гармония жизни
                                     'CHI'
                                    ,'CHI_2'
                                    , -- Дети
                                     'TERM'
                                    ,'TERM_2'
                                    , -- Семья
                                     'PEPR'
                                    ,'PEPR_2'
                                    , -- Будущее
                                     'ACC'
                                    ,'ACC163'
                                    ,'ACC164'
                                    ,'ACC172'
                                    ,'ACC173'
                                    ,'ACC_PLUS'
                                    ,'ACCExp167'
                                    ,'ACCExp168' -- Защита
                                     )
           AND pph.product_id = ppl.product_id
           AND ppl.t_product_line_id = plo.product_line_id
           AND pph.policy_id = ppp.policy_id
              /**/
           AND ppp.policy_id = ass.p_policy_id
           AND ass.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = plo.id
           AND plo.brief IN ('AVIA_RAIL_ACC_DEATH', 'PRESENT_LIFE')) phid
       /**/
      ,ins.as_insured ai
      ,ins.contact    c
       /**/
      ,ins.doc_doc    dd
      ,ins.ac_payment ap
      ,ins.document   dap
      ,ins.p_policy   pp2
       /**/
      ,ins.doc_set_off    dso
      ,ins.oper           o
      ,ins.trans          t
      ,ins.document       dso_chi
      ,ins.doc_status_ref dsr
      ,ins.doc_templ      dt
 WHERE 1 = 1
   AND phid.policy_id = d.document_id
   AND d.doc_status_id = ds.doc_status_id
      /**/
   AND phid.policy_id = ai.policy_id
   AND ai.insured_contact_id = c.contact_id
      /**/
   AND phid.policy_header_id = pp2.pol_header_id
   AND pp2.policy_id = dd.parent_id
   AND dd.child_id = ap.payment_id
   AND ap.payment_id = dap.document_id
   AND dap.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'PAID'
   AND dap.doc_templ_id = dt.doc_templ_id
   AND dt.brief = 'PAYMENT'
      /**/
   AND ap.payment_id = dso.parent_doc_id
   AND dso.cancel_date IS NULL
   AND dso.doc_set_off_id = o.document_id
   AND o.oper_id = t.oper_id
   AND o.oper_templ_id = 3201 -- Страховая премия аванс оплачен
   AND (t.a4_dt_uro_id = phid.id OR t.a4_ct_uro_id = phid.id)
   AND dso.child_doc_id = dso_chi.document_id;
