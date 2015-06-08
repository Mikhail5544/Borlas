CREATE OR REPLACE VIEW V_STATUS_REC_VERSION AS
select pp.pol_header_id,
       pp.policy_id,
       pp.pol_num pol_num,
       ph.ids,
       cpol.obj_name_orig holder,
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) last_stat,
       pp.version_num,
       (select ds.user_name
        from ins.doc_status ds,
             ins.doc_status_ref rf
        where ds.document_id = pp.policy_id
              and ds.src_doc_status_ref_id = rf.doc_status_ref_id
              and rf.name like '%Документ добав%') user_name,
       f.brief currency,
       trm.description period,
       prod.description product,
       pp.start_date,
       ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 2) date_last_payed
from ins.p_policy pp,
     ins.p_pol_header ph,
     ins.fund f,
     ins.t_contact_pol_role polr,
     ins.p_policy_contact pcnt,
     ins.contact cpol,
     ins.t_product prod,
     ins.t_payment_terms trm

where pp.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and prod.product_id = ph.product_id
      and ph.fund_id = f.fund_id
      and pp.payment_term_id = trm.id
      and pp.version_order_num is not null
      and pp.start_date between --to_date('01-11-2010','dd-mm-yyyy') and to_date('31-01-2011','dd-mm-yyyy')
                          to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'rec_ver'
                            AND r.param_name = 'date_from'),'dd.mm.yyyy') and
                            to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'rec_ver'
                            AND r.param_name = 'date_to'),'dd.mm.yyyy')
      --and pkg_policy.get_last_version_status(ph.policy_header_id) in ('Напечатан','Передано Агенту','Договор подписан')

