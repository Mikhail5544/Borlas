create or replace force view v_gen_policy_back_schedule as
select
  gp.gen_policy_id,
  d.document_id,
  d.num,
  a.due_date,
  a.grace_date,
  a.amount,
  dd.parent_amount part_amount,
  pkg_payment.get_bill_set_off_amount(d.document_id, 0) pay_amount,
  a.contact_id,
  c.obj_name_orig contact_name,
  dsr.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  dt.brief doc_templ_brief
from
  ven_gen_policy gp,
  doc_doc gdd,
  document d,
  ac_payment a,
  doc_templ dt,
  doc_doc dd,
  p_policy p,
  contact c,
  doc_status ds,
  doc_status_ref dsr
where
  gp.gen_policy_id = gdd.parent_id and
  gdd.child_id = p.pol_header_id and
  d.document_id = a.payment_id and
  d.doc_templ_id = dt.doc_templ_id and
  dt.brief in ('PAYORDBACK','PAYMENT_SETOFF') and
  dd.child_id = d.document_id and
  dd.parent_id = p.policy_id and
  a.contact_id = c.contact_id and
  ds.document_id = d.document_id and
  ds.start_date = (
    select max(dss.start_date)
    from   doc_status dss
    where  dss.document_id = d.document_id
  ) and
  dsr.doc_status_ref_id = ds.doc_status_ref_id;

