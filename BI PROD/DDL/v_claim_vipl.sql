create or replace force view v_claim_vipl as
select
  d.document_id,
  ch.c_event_id,
  ch.c_claim_header_id,
  dd.parent_id,
  pr.description,
  a.amount,
  decode(dt.brief,'PAYORDER_SETOFF','Ç',
                  'PAYORDER','Â',
                  'Í') flag
from
  document d,
  ac_payment a,
  doc_templ dt,
  doc_doc dd,
  c_claim cc,
  c_claim_header ch,
  contact c,
  doc_status ds,
  doc_status_ref dsr,
  p_policy p,
  t_peril pr
where
  d.document_id = a.payment_id
  and  d.doc_templ_id = dt.doc_templ_id
  --and  dt.brief in ('PAYORDER')
  and  dd.child_id = d.document_id
  and  dd.parent_id = cc.c_claim_id
  and  a.contact_id = c.contact_id
  and  ds.document_id = d.document_id
  and  ds.start_date = (
    select max(dss.start_date)
    from   doc_status dss
    where  dss.document_id = d.document_id)
  and  dsr.doc_status_ref_id = ds.doc_status_ref_id
  and ch.c_claim_header_id = cc.c_claim_header_id
  --and ch.c_event_id = 10912101
  and p.policy_id = ch.p_policy_id
  and pr.id = ch.peril_id
;

