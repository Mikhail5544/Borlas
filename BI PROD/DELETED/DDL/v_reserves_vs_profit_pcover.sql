create or replace view ins_dwh.v_reserves_vs_profit_pcover as
select mn.*
        ,tr.charge_premium
    from (select pc.p_cover_id
                ,pl.id          as product_line_id
                ,se.p_policy_id
                ,case tplt.brief
                   when 'MANDATORY' then 1
                   else 0
                 end as is_mandatory
                ,plo.description as plo_description
                ,plo.id          as plo_id
                ,sh.brief        as sh_brief
                ,case
                   when plo.description in ('Инвалидность застрахованного: 1,2 по любой причине, 3 НС',
                                            'Инвалидность по любой причине') then 'C'
                   when plo.description = 'Смерть по любой причине' then 'L'
                   else decode(ig.life_property,1,'L',0,'C')
                 end as type_insurance
                ,pc.is_avtoprolongation
                ,case ll.brief when 'PWOP' then decode(cn_pol_insurer.gender, 0, 1, 1, 0) end as sex_child
                ,case ll.brief when 'PWOP' then cn_pol_insurer.date_of_birth  end as date_birth_child
                ,case ll.brief when 'PWOP' then 0 end as pwop_0
                ,case ll.brief when 'PWOP' then 1 end as pwop_1
                ,pc.start_date
                ,cn_pol_insurer.obj_name as cn_pol_insurer_obj_name
                ,ll.brief as ll_brief
                ,pc.ext_id
                ,pc.insured_age
                ,pc.end_date
                ,pc.rvb_value
                ,pc.decline_date
                ,pc.normrate_value
                ,cn_pol_insurer.contact_id as cn_pol_insurer_contact_id
                ,cn_pol_insurer.date_of_death as cn_pol_insurer_date_of_death
                ,cn_pol_insurer.date_of_birth as cn_pol_insurer_date_of_birth
                ,nvl(pc.k_coef_m,0)           as k_coef_m       
                ,nvl(pc.s_coef_nm,0)          as s_coef_nm
                ,nvl(pc.k_coef_nm,0)          as k_coef_nm
                ,pc.fee
                ,pc.ins_amount
                ,ll.description   as ll_description
                ,case ig.life_property
                   when 0 then 'C'
                   when 1 then 'L'
                 end as ig_life_property
                ,ig.life_property as ig_life_property_num
                ,cn_pol_insurer.gender as cn_pol_insurer_gender
                ,pc.t_prod_line_option_id
                ,se.p_asset_header_id
                ,ll.t_lob_line_id as ll_t_lob_line_id
                ,ca.program_start
                ,ca.program_end
                ,ca.program_sum
                ,case
                   when exists(select null
                                 from ins.re_cover           rc
                                     ,ins.p_cover            pcm
                                     ,ins.as_asset           aam
                                     ,ins.t_prod_line_option plom
                                where pcm.p_cover_id       = pc.p_cover_id
                                  and aam.as_asset_id      = pcm.as_asset_id
                                  and plom.id              = pcm.t_prod_line_option_id
                                  and rc.p_asset_header_id = aam.p_asset_header_id
                                  and rc.t_product_line_id = plom.product_line_id)
                   then 'Checked'
                   else 'Unchecked'
                 end as for_re
                ,(select con.obj_name reinsurer_name
                    from ins.re_cover         rc
                        ,ins.re_main_contract mc
                        ,ins.contact          con
                   where rc.p_cover_id          = pc.p_cover_id
                     and mc.re_main_contract_id = rc.re_m_contract_id
                     and mc.reinsurer_id        = con.contact_id
                     and rownum = 1
                 ) as reinsured
                ,case
                   when plo.brief in ('Adm_Cost_Acc','Adm_Cost_Life') then
                     1
                   else
                     0
                 end as is_adm_cost
            from ins.p_cover               pc
                ,ins.as_assured            aa
                ,ins.as_asset              se
                ,ins.status_hist           sh
                ,ins.t_prod_line_option    plo
                ,ins.t_product_line        pl
                ,ins.t_lob_line            ll
                ,ins.t_insurance_group     ig
                ,ins.ven_cn_person         cn_pol_insurer
                ,ins.t_product_line_type   tplt
                ,ins_dwh.reserves_vs_profit_cover_ag ca
           where /*pc.start_date                   <= ins_dwh.pkg_reserves_vs_profit.get_report_date
             and */pc.as_asset_id                   = aa.as_assured_id
             and se.as_asset_id                   = aa.as_assured_id
             and pc.status_hist_id                = sh.status_hist_id
             and pc.t_prod_line_option_id         = plo.id
             and plo.product_line_id              = pl.id
             and pl.t_lob_line_id                 = ll.t_lob_line_id
             and ll.insurance_group_id            = ig.t_insurance_group_id
             and cn_pol_insurer.contact_id        = aa.assured_contact_id
             and pl.product_line_type_id          = tplt.product_line_type_id
             and ca.p_policy_id                   = se.p_policy_id 
             and ca.t_prod_line_option_id         = plo.id
             and (plo.brief is null or plo.brief != 'NonInsuranceClaims')
             and se.p_policy_id in (select ph.policy_id
                                      from ins.p_pol_header ph
                                          ,ins.p_policy     pp
                                          ,ins.t_product    pr
                                     where ph.product_id = pr.product_id
                                       and ph.policy_id  = pp.policy_id
                                       and ((ins_dwh.pkg_reserves_vs_profit.get_mode = 0
                                             and pr.brief not in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                                             and pp.is_group_flag = 0
                                            )or
                                            (ins_dwh.pkg_reserves_vs_profit.get_mode = 1
                                             and pr.brief in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                                            )or
                                            (ins_dwh.pkg_reserves_vs_profit.get_mode = 2
                                             and pp.is_group_flag = 1
                                            )
                                           )  
                                   )
         ) mn
         left outer join ins_dwh.reserves_vs_profit_trans_ag tr
           on mn.p_asset_header_id             = tr.p_asset_header_id
          and mn.t_prod_line_option_id         = tr.t_prod_line_option_id;
