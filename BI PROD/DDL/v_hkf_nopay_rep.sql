CREATE OR REPLACE VIEW V_HKF_NOPAY_REP AS
SELECT ph.ids "ИДС"
       ,pp.pol_num "Номер ДС"
       ,vpi.contact_name "ФИО страхователя"
       ,dsr.name "Статус п версии"
       ,tp.description "Продукт"
       ,(SELECT tpt.description FROM ins.t_payment_terms tpt WHERE tpt.id = pp.payment_term_id) "Периодичность оплаты"
       ,ph.start_date "Дата начала"
       ,pp.end_date "Дата окончания"
       ,fnd.name "Валюта отвественности"
       ,f.t_policy_form_name "Полисные условия"
       ,pps.epg "ЭПГ"
       ,pps.plan_date "Дата Графика"
       ,pps.amount "Задолженность"
       ,pps.sta "Статус ЭПГ"
  FROM ins.p_pol_header ph
      ,ins.p_policy pp
      ,ins.v_pol_issuer vpi
      ,ins.t_policyform_product tpp
      ,ins.t_policy_form f
      ,ins.t_product tp
      ,ins.fund fnd
      ,ins.document dc
      ,ins.doc_status ds
      ,ins.doc_status_ref dsr
      ,(SELECT d1.num           epg
              ,a1.plan_date
              ,a1.amount
              ,d1.document_id
              ,p1.pol_header_id
              ,p1.policy_id
              ,dsr1.name        sta
          FROM ins.document       d1
              ,ins.ac_payment     a1
              ,ins.doc_templ      dt1
              ,ins.doc_doc        dd1
              ,ins.p_policy       p1
              ,ins.doc_status     ds1
              ,ins.doc_status_ref dsr1
         WHERE d1.document_id = a1.payment_id
           AND d1.doc_templ_id = dt1.doc_templ_id
           AND dt1.brief = 'PAYMENT'
           AND dsr1.brief = 'TO_PAY'
           AND ds1.doc_status_id = d1.doc_status_id
           AND dsr1.doc_status_ref_id = ds1.doc_status_ref_id
           AND dd1.child_id = d1.document_id
           AND dd1.parent_id = p1.policy_id) pps
 WHERE pp.policy_id = ph.last_ver_id
   AND vpi.policy_id = ph.last_ver_id
   AND tp.product_id = ph.product_id
   AND tpp.t_product_id = tp.product_id
   AND f.t_policy_form_id = tpp.t_policy_form_id
   AND pp.t_product_conds_id = tpp.t_policyform_product_id
   AND fnd.fund_id = ph.fund_id
   AND pps.pol_header_id = ph.policy_header_id
   AND dc.document_id = ph.last_ver_id
   AND ds.doc_status_id = dc.doc_status_id
   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
   AND (tp.brief LIKE 'CR92_%' OR tp.brief = 'FAMILY_PROTECTION_BANK')
   AND dsr.doc_status_ref_id IN (2, 91, 20, 1, 89, 16);
