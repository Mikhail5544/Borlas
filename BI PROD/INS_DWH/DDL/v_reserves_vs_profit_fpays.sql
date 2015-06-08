CREATE OR REPLACE VIEW INS_DWH.V_RESERVES_VS_PROFIT_FPAYS AS
SELECT MIN(ap.plan_date) AS fist_to_pay_date
      ,ph.policy_header_id
  FROM ins.p_policy pp
      ,ins.doc_doc dd
      ,ins.ac_payment ap
      ,(SELECT /*+ NO_MERGE */
         d.document_id
          FROM ins.document       d
              ,ins.doc_status_ref dsr
              ,ins.doc_templ      dt
         WHERE d.doc_status_ref_id = dsr.doc_status_ref_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND dsr.brief = 'TO_PAY') ch
      ,ins.p_pol_header ph
      ,ins.t_product pr
 WHERE pp.policy_id = dd.parent_id
   AND dd.child_id = ap.payment_id
   AND dd.child_id = ch.document_id
   AND ins.pkg_payment.get_set_off_amount(ap.payment_id, ph.policy_header_id, NULL) = 0
   AND ph.policy_header_id = pp.pol_header_id
   AND ph.product_id = pr.product_id
 GROUP BY ph.policy_header_id;
