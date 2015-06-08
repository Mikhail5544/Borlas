create or replace force view v_due_payments as
select -- count(*)
-- p.PAYMENT_TERM_ID,
 trunc(a.grace_date) - trunc(sysdate) days_remaining,
 a.amount - pkg_payment.get_bill_set_off_amount(d.document_id, 0) pay_remaining,
 pt.DESCRIPTION term_description,
 p.START_DATE,
 p.pol_header_id,
 p.policy_id,
 d.document_id,
 d.num doc_num,
 a.due_date,
 a.grace_date,
 a.amount,
 pkg_payment.get_bill_set_off_amount(d.document_id, 0) pay_amount,
 a.contact_id,
 c.obj_name_orig contact_name,
 dsr.doc_status_ref_id,
 dsr.name doc_status_ref_name
  from document        d,
       ac_payment      a,
       doc_templ       dt,
       doc_doc         dd,
       p_policy        p,
       contact         c,
       doc_status      ds,
       doc_status_ref  dsr,
       T_PAYMENT_TERMS pt
 where d.document_id = a.payment_id
   and d.doc_templ_id = dt.doc_templ_id
   and dt.brief = 'PAYMENT'
   and dd.child_id = d.document_id
   and dd.parent_id = p.policy_id
   and a.contact_id = c.contact_id
   and ds.document_id = d.document_id
   and ds.start_date =
       (select max(dss.start_date)
          from doc_status dss
         where dss.document_id = d.document_id)
   and dsr.doc_status_ref_id = ds.doc_status_ref_id
   and pt.ID = p.PAYMENT_TERM_ID
   and dsr.brief <> 'PAID'
   and a.amount - pkg_payment.get_bill_set_off_amount(d.document_id, 0) > 0
;

