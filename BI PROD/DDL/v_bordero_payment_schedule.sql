CREATE OR REPLACE FORCE VIEW V_BORDERO_PAYMENT_SCHEDULE AS
SELECT
  bp.RE_BORDERO_PACKAGE_ID,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  dd.parent_amount part_amount,
  0 pay_amount,
  --pkg_payment.get_bill_set_off_amount(d.document_id, 0) pay_amount,
  --pkg_payment.get_part_set_off_amount(d.document_id, p.pol_header_id, 0) part_pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  RE_BORDERO_PACKAGE bp,
  CONTACT c,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr
WHERE
  d.document_id = a.payment_id
  AND  d.doc_templ_id = dt.doc_templ_id
  AND  dt.brief = 'AccOblOutReins'
  AND  dd.child_id = d.document_id
  AND  dd.parent_id = bp.RE_BORDERO_PACKAGE_ID
  AND  a.contact_id = c.contact_id
  AND  ds.document_id = d.document_id
  AND  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   DOC_STATUS dss
    WHERE  dss.document_id = d.document_id  )
  AND  dsr.doc_status_ref_id = ds.doc_status_ref_id
;

