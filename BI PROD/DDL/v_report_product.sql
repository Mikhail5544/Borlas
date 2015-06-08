CREATE OR REPLACE FORCE VIEW V_REPORT_PRODUCT AS
select pp.pol_header_id,
       pp.policy_id,
       ph.ids,
       pp.pol_ser,
       pp.pol_num,
       cpol.obj_name_orig holder,
       prod.description product,
       ph.start_date start_date_header,
       pp.start_date start_date_version,
       pp.end_date end_date_version,
       f.brief currency,
       trm.description period,
       opt.description progr,
       pc.ins_amount,
       pc.fee,
       pc.premium,
       dep.name depart,
       pkg_policy.get_last_version_status(ph.policy_header_id) last_state
from p_policy pp,
     p_pol_header ph,
     fund f,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     t_payment_terms trm,
     t_product prod,
     as_asset a,
     p_cover pc,
     t_prod_line_option opt,
     department dep
where pp.policy_id = ph.policy_id
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.fund_id = f.fund_id
      and pp.payment_term_id = trm.id
      and prod.product_id = ph.product_id
/*      and prod.description in
               (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'rep_prod'
                   AND r.param_name = 'name_prod')*/
      --and prod.description = 'Инвестор'
      and pp.policy_id = a.p_policy_id
      and a.as_asset_id = pc.as_asset_id
      and pc.t_prod_line_option_id = opt.id
      and ph.agency_id = dep.department_id(+)
      and ph.start_date BETWEEN to_date((SELECT r.param_value
                                          FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'rep_prod'
                                            AND r.param_name = 'date_from'),'dd.mm.yyyy')
                        AND to_date((SELECT r.param_value
                                      FROM ins_dwh.rep_param r
                                      WHERE r.rep_name = 'rep_prod'
                                        AND r.param_name = 'date_to'),'dd.mm.yyyy')
;

