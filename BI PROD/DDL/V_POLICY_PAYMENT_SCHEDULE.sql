CREATE OR REPLACE VIEW V_POLICY_PAYMENT_SCHEDULE AS
SELECT
  p.pol_header_id,
  p.policy_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
--  dd.parent_amount part_amount,
  a.amount part_amount,  -- Капля П., Заявка 173425
  Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL) pay_amount,
  Pkg_Payment.get_set_off_amount(d.document_id, p.pol_header_id,NULL) part_pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  a.plan_date,
  a.payment_number
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  P_POLICY p,
  CONTACT c,
  --DOC_STATUS ds,  --305725 /Чирков/оптимизировал
  DOC_STATUS_REF dsr
WHERE
  d.document_id = a.payment_id
  AND
  d.doc_templ_id = dt.doc_templ_id
  AND
  dt.brief = 'PAYMENT'
  AND
  dd.child_id = d.document_id
  AND
  dd.parent_id = p.policy_id
  AND
  a.contact_id = c.contact_id
  --305725 /Чирков/оптимизировал
  /*AND
  ds.document_id = d.document_id
  AND
  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   DOC_STATUS dss
    WHERE  dss.document_id = d.document_id
  )
  AND
  dsr.doc_status_ref_id = ds.doc_status_ref_id*/
  and d.doc_status_ref_id = dsr.doc_status_ref_id;
  --305725
