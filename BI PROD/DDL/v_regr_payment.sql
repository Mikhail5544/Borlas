CREATE OR REPLACE FORCE VIEW V_REGR_PAYMENT AS
SELECT d.document_id,
       d.num,
       pt.collection_method_id,
       cm.description collection_method_desc,
       cch.payment_term_id,
       pt.description payment_term_desc,
       pt.number_of_payments,
       TRUNC(ds.start_date, 'dd') first_pay_date,
       csd.fund_id,
       f.brief fund_brief,
       csd.subr_amount,
       pkg_regr_payment.get_plan_amount(d.document_id) plan_amount,
       pkg_regr_payment.get_calc_amount(d.document_id) calc_amount,
       pkg_regr_payment.get_to_pay_amount(d.document_id) to_pay_amount,
       pkg_regr_payment.get_pay_subrog_amount_pfa(TO_DATE('01.01.1900','DD.MM.YYYY'), TO_DATE('01.01.3000','DD.MM.YYYY'), d.document_id) pay_amount
  FROM DOCUMENT            d,
       C_SUBR_DOC          csd,
       C_CLAIM_HEADER      cch,
       FUND                f,
       T_PAYMENT_TERMS     pt,
       T_COLLECTION_METHOD cm,
       DOC_STATUS          ds
 WHERE d.document_id = csd.c_subr_doc_id AND
       csd.fund_id = f.fund_id AND
       csd.c_claim_header_id = cch.c_claim_header_id AND
       cch.payment_term_id = pt.ID AND
       pt.collection_method_id = cm.ID AND
       ds.document_id = d.document_id AND       
       ds.start_date = (
         SELECT MAX(dss.start_date)
         FROM   DOC_STATUS dss
         WHERE  dss.document_id = d.document_id
       );

