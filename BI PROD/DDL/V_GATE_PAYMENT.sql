CREATE OR REPLACE VIEW V_GATE_PAYMENT AS
SELECT pp.policy_id,
       epg.payment_id epg_id,
       epg.plan_date,
       doc.get_doc_status_name(epg.payment_id) epg_stat,
       epg.amount epg_amount,
       pay.doc_temp pay_type,
       pay.pay_date,
       pay.payment_id,
       pay.amount,
       pay.pay_status,
       pay.is_annulated
      -- Байтин А.
      -- Добавлена дата перевода статуса платежного документа
      ,pay.status_date
  FROM p_policy pp,
       doc_doc dd,
       ven_ac_payment epg,
       doc_templ dt,
       (SELECT dso.parent_doc_id,
               dt1.name doc_temp,
               CASE WHEN dt1.brief IN ('ПП','ПП_ПС','ПП_ОБ') THEN pay_doc.payment_id ELSE bank_doc.payment_id END payment_id,
               CASE WHEN dt1.brief IN ('ПП','ПП_ПС','ПП_ОБ') THEN dso.set_off_child_amount ELSE bank_doc.set_off_child_amount END amount,
               pay_doc.due_date pay_date,
             --  CASE WHEN dt1.brief IN ('ПП','ПП_ПС','ПП_ОБ') THEN pay_doc.due_date ELSE bank_doc.due_date END pay_date,
               CASE WHEN dt1.brief IN ('ПП','ПП_ПС','ПП_ОБ') THEN doc.get_doc_status_name(pay_doc.payment_id)
                    ELSE doc.get_doc_status_name(bank_doc.set_of_doc) END pay_status,
               DECODE(dso.CANCEL_DATE, NULL, '', 'Annulated') is_annulated
              ,doc.get_last_doc_status_date(dso.doc_set_off_id) as status_date
          FROM doc_set_off dso,
               ven_ac_payment pay_doc,
               doc_templ dt1,
               (SELECT dd2.parent_id,
                      dso2.set_off_child_amount,
                      acp.due_date,
                      acp.payment_id,
                      dso2.doc_set_off_id set_of_doc
                 FROM doc_doc dd2,
                      doc_set_off dso2,
                      ac_payment acp
                WHERE dso2.parent_doc_id = dd2.child_id
                  AND acp.payment_id = dso2.child_doc_id) bank_doc
         WHERE dso.child_doc_id = pay_doc.payment_id
           AND dt1.doc_templ_id = pay_doc.doc_templ_id
           AND pay_doc.payment_id = bank_doc.parent_id (+)) pay
 WHERE pp.policy_id = dd.parent_id
   AND dd.child_id = epg.payment_id
   AND epg.doc_templ_id = dt.doc_templ_id
   AND dt.brief = 'PAYMENT' -- Счет на оплату взносов (ЭПГ)
   --AND doc.get_doc_status_brief(epg.payment_id)<>'NEW'
   AND pay.parent_doc_id (+) = epg.payment_id;
