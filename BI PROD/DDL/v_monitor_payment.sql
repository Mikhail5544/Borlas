CREATE OR REPLACE FORCE VIEW V_MONITOR_PAYMENT AS
select sch.pol_num,
       --c.name||' '||c.first_name||' '||c.middle_name,
       sch.due_date,
       sch.grace_date,
       sch.plan_date,
       sch.amount,
       sch.part_amount,
       Pkg_Payment.get_set_off_amount(sch.payment_id, NULL, NULL) pay_amount,
       Pkg_Payment.get_set_off_amount(sch.payment_id, sch.pol_header_id,NULL) part_pay_amount,
       sch.num,
       sch.payment_number,
       trunc(ds.change_date) change_date,
       ds.user_name,
       rf.name
from (SELECT d.document_id,
             p.policy_id,
             a.payment_id,
             decode(p.pol_ser, null, p.pol_num, p.pol_ser || '-' || p.pol_num) pol_num,
             a.due_date,
             a.grace_date,
             a.plan_date,
             a.amount,
             dd.parent_amount part_amount,
             p.pol_header_id,
             d.num,
             a.payment_number
      FROM DOCUMENT d,
           AC_PAYMENT a,
           DOC_TEMPL dt,
           DOC_DOC dd,
           P_POLICY p,
           CONTACT c,
           DOC_STATUS ds,
           DOC_STATUS_REF dsr
      WHERE d.document_id = a.payment_id
            AND d.doc_templ_id = dt.doc_templ_id
            AND dt.brief in ('PAYMENT'/*'A7COPY','PD4COPY'*/)
            AND dd.child_id = d.document_id
            AND dd.parent_id = p.policy_id
            AND a.contact_id = c.contact_id
            AND ds.document_id = d.document_id
            AND ds.start_date = (SELECT MAX(dss.start_date)
                                 FROM   DOC_STATUS dss
                                 WHERE  dss.document_id = d.document_id)
            AND dsr.doc_status_ref_id = ds.doc_status_ref_id
            /*and p.policy_id = 7162447*/) sch
   join ven_ac_payment ap ON ap.payment_id = sch.document_id
   join doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   join ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   join doc_doc ddd on (ddd.parent_id = ap1.payment_id)
   join doc_set_off dof1 on (dof1.parent_doc_id = ddd.child_id)
   left join doc_status ds on (dof1.doc_set_off_id = ds.document_id)
   left join doc_status_ref rf on (rf.doc_status_ref_id = ds.doc_status_ref_id)
--where sch.policy_id = 7162447
;

