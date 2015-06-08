CREATE OR REPLACE VIEW v_rep_undrw_netting AS
select ph.policy_header_id,
       pp.policy_id,
       ph.ids,
       pp.pol_num,
       pp.notice_num,
       prod.description prod,
       ph.start_date,
       pp.confirm_date,
       pp.end_date,
       cpol.obj_name_orig holder,
       pkg_policy.get_last_version_status(ph.policy_header_id) last_status_header,
       doc.get_doc_status_brief(ph.policy_id) active_status_version,
       (select max(ds.start_date)
        from document d,
             doc_status ds,
             doc_status_ref rf
        where d.document_id = ph.policy_id
              and d.document_id = ds.document_id
              and ds.doc_status_ref_id = rf.doc_status_ref_id) date_active_status_version,
       round(pkg_payment.get_plan_ret_amount(ph.policy_header_id),2) sum_plan,
       round(pkg_payment.get_calc_ret_amount(ph.policy_header_id),2) sum_nach
from /*(select max(p.version_num) + 1 undr_ver_num, phu.policy_header_id
      from p_pol_header phu,
           p_policy p
      where phu.policy_header_id = p.pol_header_id
        and doc.get_doc_status_brief(p.policy_id) = 'UNDERWRITING'
      group by phu.policy_header_id) p_undr,*/
     p_pol_header ph,
     t_product prod,
     p_policy pp,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol
where pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.product_id = prod.product_id
/*      and p_undr.policy_header_id = ph.policy_header_id
      and pp.version_num = p_undr.undr_ver_num*/
      and (nvl(pkg_payment.get_plan_ret_amount(ph.policy_header_id),0) > 0
           and nvl(pkg_payment.get_calc_ret_amount(ph.policy_header_id),0) > 0)
      and ph.policy_header_id IN
                 (
                  select PHU.POLICY_HEADER_ID
                  from p_pol_header phu,
                       p_policy p
                  where phu.policy_header_id = p.pol_header_id
                    and doc.get_doc_status_brief(p.policy_id) = 'UNDERWRITING'
                 )
      and ph.start_date between to_date((SELECT r.param_value
                                        FROM ins_dwh.rep_param r
                                        WHERE r.rep_name = 'undrw_netting'
                                          AND r.param_name = 'date_from'),'dd.mm.yyyy')
                                      AND
                                to_date((SELECT r.param_value
                                        FROM ins_dwh.rep_param r
                                        WHERE r.rep_name = 'undrw_netting'
                                          AND r.param_name = 'date_to'),'dd.mm.yyyy') ;
           
GRANT SELECT ON v_rep_undrw_netting TO INS_EUL;