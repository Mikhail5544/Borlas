create or replace force view v_epg_list_amount as
select policy_header_id,
       pol_num,
       holder,
       date_start,
       status,
       date_epg,
       sum_epg,
       zach_epg,
       templ,
       num_doc,
       sum_doc,
       date_doc,
       list_amount,
       doc_amount,
       main_set_off_amount,
       list_set_off_amount

from (
select
      ph.policy_header_id,
      p.pol_num,
      ent.obj_name('CONTACT',pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')) holder,
      ph.start_date date_start,
      doc.get_doc_status_name(ph.policy_id) status,
      ap.plan_date date_epg,
      dd.parent_amount sum_epg,
      Pkg_Payment.get_set_off_amount(d.document_id, p.pol_header_id,NULL) zach_epg,
      dto.name templ,
      case when dto.name = 'Платежное поручение входящее' then apd.num
           else df.num end num_doc,
      case when dto.name = 'Платежное поручение входящее' then apo.amount
           else acf.rev_amount end sum_doc,
      case when dto.name = 'Платежное поручение входящее' then apo.due_date
           else acf.due_date end date_doc,
      o.doc_set_off_id,
       CASE
                                WHEN(ap.payment_type_id = 0) THEN   ap.amount
                                                                 + ap.comm_amount
                                                                 - Pkg_Payment.get_paym_set_off_amount
                                                                                 (ap.payment_id,
                                                                                  o.doc_set_off_id)
                                WHEN(ap.payment_type_id = 1) THEN   ap.amount
                                                                 + ap.comm_amount
                                                                 - Pkg_Payment.get_bill_set_off_amount
                                                                                 (ap.payment_id,
                                                                                  o.doc_set_off_id)
                             END list_amount,
      CASE
                                WHEN(o.cancel_date IS NOT NULL) THEN 0
                                WHEN(ap.payment_type_id = 0) THEN o.set_off_amount
                                WHEN(ap.payment_type_id = 1) THEN o.set_off_child_amount
                             END main_set_off_amount,
                             CASE
                                WHEN(o.cancel_date IS NOT NULL) THEN 0
                                WHEN(ap.payment_type_id = 0) THEN o.set_off_child_amount
                                WHEN(ap.payment_type_id = 1) THEN o.set_off_amount
                             END list_set_off_amount,
                             ap.amount + ap.comm_amount doc_amount
      /*,
      ddo.*,
      o1.*,
      acf.*, df.num*/
      --apo.grace_date


 from p_policy     p,
      p_pol_header ph,
      doc_doc      dd,
      document     d,
      doc_templ    dt,
      ac_payment   ap,
      --temp_group_policy tmp,
      doc_set_off o,
      document do,
      doc_templ dto,
      ac_payment apo,
      document apd,

      doc_doc ddo,
      doc_set_off o1,
      ac_payment acf,
      document df

where ph.policy_header_id = p.pol_header_id
      and nvl(p.is_group_flag,0) = 1
      --and ph.policy_header_id = tmp.id
      and dd.parent_id = p.policy_id
      and d.document_id = dd.child_id
      and dt.doc_templ_id = d.doc_templ_id
      and dt.brief = 'PAYMENT'

      and o.parent_doc_id = ap.payment_id
      and do.document_id = o.doc_set_off_id
      and o.child_doc_id = apo.payment_id
      and apd.document_id = apo.payment_id
      and apd.doc_templ_id = dto.doc_templ_id

      and ddo.parent_id(+) = apo.payment_id
      and o1.parent_doc_id(+) = ddo.child_id
      and acf.payment_id(+) = o1.child_doc_id
      and df.document_id(+) = acf.payment_id

      and ap.payment_id = dd.child_id
      and doc.get_doc_status_brief(d.document_id) not in ('ANNULATED')
      --and p.pol_num = '111072'
order by p.pol_header_id,ap.plan_date)
--where date_doc between to_date('01.01.2009','dd.mm.yyyy') and to_date('31.12.2009','dd.mm.yyyy')
;

