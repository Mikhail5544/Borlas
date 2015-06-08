create or replace force view v_re_claim_payment_schedule as
select
  rch.re_claim_header_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  a.rev_amount, 
  pkg_payment.get_bill_set_off_amount(d.document_id, 0) pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name
from
  document d,
  ac_payment a,
  doc_templ dt,
  doc_doc dd,
  re_claim_header rch,
  contact c,
  doc_status ds,
  doc_status_ref dsr
where
  d.document_id = a.payment_id
  and
  d.doc_templ_id = dt.doc_templ_id 
  and 
  dt.brief = 'AccPayOutReins'
  and
  dd.child_id = d.document_id
  and
  dd.parent_id = rch.re_claim_header_id
  and
  a.contact_id = c.contact_id
  and
  ds.document_id = d.document_id
  and
  ds.start_date = (
    select max(dss.start_date)
    from   doc_status dss
    where  dss.document_id = d.document_id
  )
  and
  dsr.doc_status_ref_id = ds.doc_status_ref_id;

