create or replace view v_REP_bank_policies as
WITH ap AS
 (SELECT /*+INLINE*/
   ap.amount
  ,ap.payment_id
  ,ap.due_date
  ,apt.brief payment_templ_brief
  ,pp2.pol_header_id
  ,ap.contact_id
  ,dt.brief doc_templ_brief
    FROM doc_doc          dd
        ,ac_payment       ap
        ,ac_payment_templ apt
        ,p_policy         pp2
        ,document d
        ,doc_status_ref dsr
        ,doc_templ dt
   WHERE dd.child_id = ap.payment_id
     AND dd.parent_id = pp2.policy_id
     AND ap.PAYMENT_TEMPL_ID = apt.payment_templ_id
     and ap.payment_id = d.document_id
     and d.doc_status_ref_id = dsr.doc_status_ref_id
     and d.doc_templ_id = dt.doc_templ_id
     and dsr.brief != 'ANNULATED'
     AND ap.cancel_date IS NULL),
dso AS
 (SELECT /*+INLINE*/
   ap.*
  ,dso1.set_off_amount
  ,ap2.num
  ,ap2.due_date ap2_due_date
    FROM ap
        ,doc_set_off    dso1
        ,ven_ac_payment ap2
   WHERE ap.payment_id = dso1.parent_doc_id
     AND dso1.cancel_date IS NULL
     AND dso1.child_doc_id = ap2.payment_id)

SELECT pp.pol_num
      ,ph.ids
      ,(SELECT pli.contact_name FROM v_pol_issuer pli WHERE pli.policy_id = pp.policy_id) contact_name
      ,p.brief
      ,(SELECT wm_concat(obj_name_orig)
          FROM contact    c
              ,as_assured aas
              ,as_asset   aa
         WHERE aas.as_assured_id = aa.as_asset_id
           AND aas.assured_contact_id = c.contact_id
           AND aa.p_policy_id = pp.policy_id) assured_name
      ,ph.start_date
      ,trunc(pp.end_date) end_date
      ,pp.ins_amount
      /*,(SELECT sum(amount)
          FROM ap
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYMENT') epg_amount*/
			,(SELECT SUM(aa.fee) FROM as_asset aa WHERE aa.p_policy_id = pp.policy_id) epg_amount
      ,(SELECT SUM(dso.set_off_amount)
          FROM dso
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYMENT') set_off_amount
      ,(SELECT wm_concat(num)
          FROM dso
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYMENT') pp_nums
      ,(SELECT MAX(ap2_due_date)
          FROM dso
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYMENT') pp_date
      ,(SELECT f.brief FROM fund f WHERE ph.fund_id = f.fund_id) fund_brief
      ,(SELECT dsr.name
          FROM document       d
              ,doc_status_ref dsr
         WHERE d.document_id = pp.policy_id
           AND dsr.doc_status_ref_id = d.doc_status_ref_id) status
      ,(SELECT dr.name FROM t_decline_reason dr WHERE dr.t_decline_reason_id = pp.decline_reason_id) declane_reason
      ,CASE
         WHEN pp.decline_reason_id IN (184, 225, 183, 222, 185)
              AND pp.decline_reason_id IS NOT NULL THEN
          'Аннулирование'
         WHEN pp.decline_reason_id IS NOT NULL THEN
          'Расторжение'
         ELSE
          NULL
       END AS decline_type
      ,CASE
         WHEN (SELECT COUNT(*)
                 FROM ap
                     ,document  d
                     ,doc_templ dt
                WHERE pol_header_id = ph.policy_header_id
                  AND due_date = trunc(pp.start_date)
                  AND payment_templ_brief = 'PAYREQ'
                  AND payment_id = d.document_id
                  AND d.doc_templ_id = dt.doc_templ_id
                  AND dt.brief = 'PAYREQ') > 1 THEN
          'Несколько получателей: ' || (SELECT to_char(COUNT(*))
                                          FROM ap
                                              ,document  d
                                              ,doc_templ dt
                                         WHERE pol_header_id = ph.policy_header_id
                                           AND due_date = trunc(pp.start_date)
                                           AND payment_templ_brief = 'PAYREQ'
                                           AND payment_id = d.document_id
                                           AND d.doc_templ_id = dt.doc_templ_id
                                           AND dt.brief = 'PAYREQ')
         ELSE
          (SELECT decode(c.contact_type_id, 3, 'Клиент', 'Банк')
             FROM ap
                 ,document  d
                 ,doc_templ dt
                 ,contact   c
            WHERE pol_header_id = ph.policy_header_id
              AND due_date = trunc(pp.start_date)
              AND payment_templ_brief = 'PAYREQ'
              AND payment_id = d.document_id
              AND d.doc_templ_id = dt.doc_templ_id
              AND dt.brief = 'PAYREQ'
              AND ap.contact_id = c.contact_id)
       END initiator
      ,(SELECT SUM(amount)
          FROM ap
              ,document  d
              ,doc_templ dt
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYREQ'
           AND payment_id = d.document_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYREQ') payreq_amount
      ,(SELECT MAX(due_date)
          FROM ap
              ,document  d
              ,doc_templ dt
         WHERE pol_header_id = ph.policy_header_id
           AND due_date = trunc(pp.start_date)
           AND payment_templ_brief = 'PAYREQ'
           AND payment_id = d.document_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYREQ') payreq_date
      ,(SELECT trunc(ds.start_date)
          FROM document   d
              ,doc_status ds
         WHERE d.document_id = pp.policy_id
           AND d.doc_status_id = ds.doc_status_id) status_date
  FROM p_pol_header ph
      ,p_policy     pp
      ,t_product    p
 WHERE ph.product_id = p.product_id
   AND ph.last_ver_id = pp.policy_id
--   and p.brief = 'CRit_1'
--   order by epg_amount desc
      --AND ph.ids = 2020006822
   AND p.brief LIKE (SELECT nvl(TRIM(r.param_value), '%')
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'bank_policies_report'
                        AND r.param_name = 'product_brief') --|| '%'
   AND ph.start_date BETWEEN (SELECT to_date(r.param_value, 'dd.mm.yyyy')
                                FROM ins_dwh.rep_param r
                               WHERE r.rep_name = 'bank_policies_report'
                                 AND r.param_name = 'START_DATE')
   AND (SELECT to_date(r.param_value, 'dd.mm.yyyy')
          FROM ins_dwh.rep_param r
         WHERE r.rep_name = 'bank_policies_report'
           AND r.param_name = 'END_DATE');
grant
  SELECT ON v_REP_bank_policies TO ins_eul;
