CREATE OR REPLACE FORCE VIEW V_RE_SET_OFF AS
SELECT
  dso.parent_doc_id,
  dso.doc_set_off_id,
  dso.child_doc_id,
  cd.num child_doc_num,
  cp.due_date child_doc_date,
  dso.set_off_date,
  dso.set_off_child_amount set_off_amount,
  (cp.amount+cp.comm_amount) child_doc_amount,
  cp.contact_id,
  cc.obj_name_orig contact_name,
  ds.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  cd.doc_templ_id,
  dt.brief doc_templ_brief,
  dt.name doc_templ_name
FROM
  DOC_SET_OFF dso,
  DOCUMENT cd,
  AC_PAYMENT cp,
  CONTACT cc,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr,
  DOC_TEMPL dt
WHERE
  dso.child_doc_id = cd.document_id AND
  cd.document_id = cp.payment_id AND
  cp.contact_id = cc.contact_id AND
  ds.document_id = cd.document_id AND
  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   DOC_STATUS dss
    WHERE  dss.document_id = cd.document_id
  )
  AND  dsr.doc_status_ref_id = ds.doc_status_ref_id
  AND  dt.doc_templ_id = cd.doc_templ_id;

