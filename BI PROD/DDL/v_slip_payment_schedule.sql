CREATE OR REPLACE FORCE VIEW V_SLIP_PAYMENT_SCHEDULE AS
SELECT
  s.re_slip_id,
  s.re_slip_header_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  dd.parent_amount part_amount,
  pkg_reins_payment.get_slip_set_off_amount(a.payment_id, 2, 0) pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.NAME doc_status_ref_name
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  RE_SLIP s,
  CONTACT c,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr
WHERE
  d.document_id = a.payment_id
  AND  d.doc_templ_id = dt.doc_templ_id
  AND  dt.brief IN ('AccFakOutReins', 'AccFakInReins')
  AND  dd.child_id = d.document_id
  AND  dd.parent_id = s.re_slip_id
  AND  a.contact_id = c.contact_id
  AND  ds.document_id = d.document_id
  AND  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   DOC_STATUS dss
    WHERE  dss.document_id = d.document_id  )
  AND  dsr.doc_status_ref_id = ds.doc_status_ref_id;

