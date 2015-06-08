CREATE OR REPLACE FORCE VIEW V_POLICY_BACK_SCHEDULE AS
SELECT
  p.pol_header_id,
  p.policy_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  Pkg_Payment.GET_BILL_SET_OFF_AMOUNT(d.document_id, null) pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  dt.brief doc_templ_brief
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  P_POLICY p,
  CONTACT c,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr
WHERE
  d.document_id = a.payment_id
  AND
  d.doc_templ_id = dt.doc_templ_id
  AND
  dt.brief IN ('PAYORDBACK','PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
  AND
  dd.child_id = d.document_id
  AND
  dd.parent_id = p.policy_id
  AND
  a.contact_id = c.contact_id
  AND
  ds.document_id = d.document_id
  AND
  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   DOC_STATUS dss
    WHERE  dss.document_id = d.document_id
  )
  AND
  dsr.doc_status_ref_id = ds.doc_status_ref_id;

