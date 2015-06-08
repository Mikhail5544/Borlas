CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_EPG_VERIFIC AS
SELECT --COUNT(*)
       ph.ids,
       p.pol_num,
       ins.doc.get_doc_status_name(ph.policy_id,TO_DATE('01.01.2999','dd.mm.yyyy')) "Статус акт версии",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь')) "Страхователь",
       pr.DESCRIPTION  "Продукт",
       ph.start_date   "Дата начала ДС",
       tpt.DESCRIPTION "Периодичность оплаты",
       sc.DESCRIPTION "Канал продаж",
       (SELECT MAX(ap.plan_date)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap,
               ins.doc_set_off   dso
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) IN ('PAID','TO_PAY')
           AND dso.parent_doc_id = ap.payment_id
       ) "Дата посл опл ЭПГ",
       (SELECT SUM(ap.amount)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap,
               ins.doc_set_off   dso
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           AND dso.parent_doc_id = ap.payment_id
           AND ap.plan_date = (SELECT MAX(ap3.plan_date)
                                 FROM ins.p_policy  p3,
                                      ins.doc_doc   dd3,
                                      ins.document  d3,
                                      ins.doc_templ dt3,
                                      ins.ac_payment ap3
                                WHERE p3.pol_header_id = ph.policy_header_id
                                  AND dd3.parent_id = p3.policy_id
                                  AND d3.document_id = dd3.child_id
                                  AND dt3.doc_templ_id = d3.doc_templ_id
                                  AND dt3.brief = 'PAYMENT'
                                  AND ap3.payment_id = d3.document_id
                                  AND ins.doc.get_doc_status_brief(ap3.payment_id) IN ('PAID','TO_PAY')
                              )
       ) "Сумма посл опл ЭПГ",
       (SELECT MIN(ap.plan_date)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) = 'NEW'
       ) "Дата первого неопл ЭПГ",
       (SELECT FLOOR(MONTHS_BETWEEN(MAX(ap.plan_date),ph.start_date)/12)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap,
               ins.doc_set_off   dso
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) IN ('PAID','TO_PAY')
           AND dso.parent_doc_id = ap.payment_id
       ) "Оплаченный год действия ДС",
       (SELECT MIN(ap.grace_date)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) = 'NEW'
       ) "Срок платежа 1 неоплач ЭПГ",
       (SELECT MAX(apay.due_date)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap,
               ins.doc_set_off   dso,
               ins.ac_payment apay
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) IN ('PAID','TO_PAY')
           AND dso.parent_doc_id = ap.payment_id
           AND apay.payment_id = dso.child_doc_id
       ) "Дата оплаты",
       (SELECT SUM(dso.set_off_child_amount)
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap,
               ins.doc_set_off   dso
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) IN ('PAID','TO_PAY')
           AND dso.parent_doc_id = ap.payment_id
           AND ap.plan_date = (SELECT MAX(ap3.plan_date)
                                 FROM ins.p_policy  p3,
                                      ins.doc_doc   dd3,
                                      ins.document  d3,
                                      ins.doc_templ dt3,
                                      ins.ac_payment ap3
                                WHERE p3.pol_header_id = ph.policy_header_id
                                  AND dd3.parent_id = p3.policy_id
                                  AND d3.document_id = dd3.child_id
                                  AND dt3.doc_templ_id = d3.doc_templ_id
                                  AND dt3.brief = 'PAYMENT'
                                  AND ap3.payment_id = d3.document_id
                                  AND ins.doc.get_doc_status_brief(ap3.payment_id) IN ('PAID','TO_PAY')
                              )
       ) "Сумма оплаты",
       f.brief "Валюта по ДС"

  FROM ins.p_pol_header ph,
       ins.t_product    pr,
       ins.t_payment_terms tpt,
       ins.p_policy  p,
       ins.fund      f,
       ins.t_sales_channel sc
 WHERE 1=1
   AND pr.product_id = ph.product_id
   AND p.policy_id = ph.policy_id
   AND tpt.id = p.payment_term_id
   AND f.fund_id = ph.fund_id
   AND ins.doc.get_doc_status_brief(ph.policy_id,TO_DATE('01.01.2999','dd.mm.yyyy')) <> 'CANCEL'

   AND ph.start_date BETWEEN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'DATE_FROM')
                         AND (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'DATE_TO')
   AND p.end_date BETWEEN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'DATE_END_FROM')
                      AND (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'DATE_END_TO')
   AND ins.doc.get_doc_status_name(ph.policy_id,TO_DATE('01.01.2999','dd.mm.yyyy')) IN
                         (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'STATUS')
  /* AND sc.DESCRIPTION IN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'SALES_CHANNEL')
   AND pr.DESCRIPTION IN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'EPG_VERIFIC' AND param_name = 'PRODUCT')*/


--AND ph.policy_header_id =819642
--F_WRITE_PARAM('EPG_VERIFIC','PRODUCT',PRODUCT)
--F_WRITE_PARAM('EPG_VERIFIC','DATE_FROM',:"Дата с")
;

