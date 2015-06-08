create or replace force view v_regr_payment_set_off as
select
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
  dt.brief doc_templ_brief
from
  doc_set_off dso,
  document cd,
  ac_payment cp,
  contact cc,
  doc_status ds,
  doc_status_ref dsr,
  doc_templ dt
where
  dso.child_doc_id = cd.document_id and
  cd.document_id = cp.payment_id and
  cp.contact_id = cc.contact_id and
  ds.document_id = cd.document_id and
  ds.start_date = (
    select max(dss.start_date)
    from   doc_status dss
    where  dss.document_id = cd.document_id
  )
  and
  dsr.doc_status_ref_id = ds.doc_status_ref_id
  and
  dt.doc_templ_id = cd.doc_templ_id;

