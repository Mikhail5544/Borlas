create or replace view v_claim_payment_schedule as
select
  cc.c_claim_header_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  a.rev_amount,
  pkg_claim_payment.get_claim_paiment_setoff(d.document_id) pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  dt.name doc_templ_name,
  dt.brief doc_templ_brief
from
  document d,
  ac_payment a,
  doc_templ dt,
  doc_doc dd,
  c_claim cc,
  contact c,
  doc_status ds,
  doc_status_ref dsr
where
  d.document_id = a.payment_id
  and  d.doc_templ_id = dt.doc_templ_id
  and  dt.brief in ('PAYORDER', 'PAYORDER_SETOFF') 
  and  dd.child_id = d.document_id
  and  dd.parent_id = cc.c_claim_id
  and  a.contact_id = c.contact_id
  and  ds.doc_status_id = d.doc_status_id
  and  dsr.doc_status_ref_id = ds.doc_status_ref_id
