CREATE OR REPLACE FORCE VIEW PAYMENT_NEW_TOPAY AS
select kk.num,
       kk.notice_num,
       kk.sale_desc,
       kk.f_resp,
       kk.f_pay,
       kk.notice_date,
       kk.start_date,
       kk.end_date,
       kk.ins_amount,
       kk.premium,
       kk.pay_term_name,
       kk.status_name,
       kk.insurer_name,
       kk.agency_name,
       pr.description as product,
       a.payment_number,
       a.plan_date,
       ds.name_pl
from v_policy_version_journal kk
     left join p_policy_contact pc on (pc.policy_id = kk.policy_id and pc.contact_policy_role_id = 1)
     left join contact cc on (cc.contact_id = pc.contact_id)
     left join t_product pr on (pr.product_id = kk.product_id)

      left join (SELECT
                    p.pol_header_id,
                    a.payment_id,
                    a.amount,
                    a.payment_number,
                    a.plan_date
                  FROM
                    DOCUMENT d,
                    AC_PAYMENT a,
                    DOC_TEMPL dt,
                    DOC_DOC dd,
                    P_POLICY p,
                    CONTACT c,
                    DOC_STATUS ds,
                    DOC_STATUS_REF dsr
                  WHERE
                    d.document_id = a.payment_id
                    AND d.doc_templ_id = dt.doc_templ_id
                    AND dt.brief = 'PAYMENT'
                    AND dd.child_id = d.document_id
                    AND dd.parent_id = p.policy_id
                    AND a.contact_id = c.contact_id
                    AND ds.document_id = d.document_id
                    AND ds.start_date = (
                      SELECT MAX(dss.start_date)
                      FROM   DOC_STATUS dss
                      WHERE  dss.document_id = d.document_id
                    )
                    AND dsr.doc_status_ref_id = ds.doc_status_ref_id) a on (a.pol_header_id = kk.policy_header_id)

       /*left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)--
       left join document dz on (dz.document_id = dso.child_doc_id)
       left join ac_payment az on (dz.document_id = az.payment_id)*/

       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.payment_id = ds.document_id )



where kk.active_policy_id = kk.policy_id
      and ds.name_pl in ('К оплате','Новый')
      and a.payment_number > 1
      and a.plan_date between to_date('01-01-2004','dd-mm-yyyy') and to_date('31-12-2010','dd-mm-yyyy')
;

