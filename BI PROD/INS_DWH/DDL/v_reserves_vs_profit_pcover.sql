CREATE OR REPLACE VIEW INS_DWH.V_RESERVES_VS_PROFIT_PCOVER AS
SELECT mn.*
      ,tr.charge_premium
  FROM (SELECT pc.p_cover_id
               ,pl.id AS product_line_id
               ,se.p_policy_id
               ,CASE tplt.brief
                  WHEN 'MANDATORY' THEN
                   1
                  ELSE
                   0
                END AS is_mandatory
               ,plo.description AS plo_description
               ,plo.id AS plo_id
               ,sh.brief AS sh_brief
               ,CASE
                  WHEN plo.description IN ('Инвалидность застрахованного: 1,2 по любой причине, 3 НС'
                                          ,'Инвалидность по любой причине') THEN
                   'C'
                  WHEN plo.description = 'Смерть по любой причине' THEN
                   'L'
                  ELSE
                   decode(ig.life_property, 1, 'L', 0, 'C')
                END AS type_insurance
               ,pc.is_avtoprolongation
               ,CASE ll.brief
                  WHEN 'PWOP' THEN
                   decode(cn_pol_insurer.gender, 0, 1, 1, 0)
                END AS sex_child
               ,CASE ll.brief
                  WHEN 'PWOP' THEN
                   cn_pol_insurer.date_of_birth
                END AS date_birth_child
               ,CASE ll.brief
                  WHEN 'PWOP' THEN
                   0
                END AS pwop_0
               ,CASE ll.brief
                  WHEN 'PWOP' THEN
                   1
                END AS pwop_1
               ,pc.start_date
               ,cn_pol_insurer.obj_name AS cn_pol_insurer_obj_name
               ,ll.brief AS ll_brief
               ,pc.ext_id
               ,pc.insured_age
               ,pc.end_date
               ,pc.rvb_value
               ,pc.decline_date
               ,pc.normrate_value
               ,cn_pol_insurer.contact_id AS cn_pol_insurer_contact_id
               ,cn_pol_insurer.date_of_death AS cn_pol_insurer_date_of_death
               ,cn_pol_insurer.date_of_birth AS cn_pol_insurer_date_of_birth
               ,nvl(pc.k_coef_m, 0) AS k_coef_m
               ,nvl(pc.s_coef_nm, 0) AS s_coef_nm
               ,nvl(pc.k_coef_nm, 0) AS k_coef_nm
               ,pc.fee
               ,pc.ins_amount
               ,ll.description AS ll_description
               ,CASE ig.life_property
                  WHEN 0 THEN
                   'C'
                  WHEN 1 THEN
                   'L'
                END AS ig_life_property
               ,ig.life_property AS ig_life_property_num
               ,cn_pol_insurer.gender AS cn_pol_insurer_gender
               ,pc.t_prod_line_option_id
               ,se.p_asset_header_id
               ,ll.t_lob_line_id AS ll_t_lob_line_id
               ,ca.program_start
               ,ca.program_end
               ,ca.program_sum
               ,CASE
                  WHEN EXISTS (SELECT NULL
                          FROM ins.re_cover           rc
                              ,ins.p_cover            pcm
                              ,ins.as_asset           aam
                              ,ins.t_prod_line_option plom
                         WHERE pcm.p_cover_id = pc.p_cover_id
                           AND aam.as_asset_id = pcm.as_asset_id
                           AND plom.id = pcm.t_prod_line_option_id
                           AND rc.p_asset_header_id = aam.p_asset_header_id
                           AND rc.t_product_line_id = plom.product_line_id) THEN
                   'Checked'
                  ELSE
                   'Unchecked'
                END AS for_re
               ,(SELECT con.obj_name reinsurer_name
                   FROM ins.re_cover         rc
                       ,ins.re_main_contract mc
                       ,ins.contact          con
                  WHERE rc.p_cover_id = pc.p_cover_id
                    AND mc.re_main_contract_id = rc.re_m_contract_id
                    AND mc.reinsurer_id = con.contact_id
                    AND rownum = 1) AS reinsured
               ,CASE
                  WHEN plo.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life') THEN
                   1
                  ELSE
                   0
                END AS is_adm_cost
               , /*(SELECT min(pp.version_num)
                                                   FROM ins.p_policy pp
                                                       ,ins.as_asset se_
                                                       ,ins.p_cover  pc_
                                                  WHERE pp.is_group_flag = 1
                                                    AND se_.p_asset_header_id = se.p_asset_header_id
                                                    AND pc_.t_prod_line_option_id = pc.t_prod_line_option_id
                                                    AND se_.p_policy_id = pp.policy_id
                                                    AND se_.as_asset_id = pc_.as_asset_id
                                                    AND pc_.status_hist_id = 1 -- 'NEW'
                                                 )*/to_number(NULL) AS version_risk_incl -- Версия включения риска
               ,(SELECT ls.k_non_med
                   FROM ins.t_product_line_sav ls
                  WHERE ls.product_line_id = pl.id
                    AND pc.start_date BETWEEN ls.start_date AND ls.end_date
                    AND pc.ins_amount BETWEEN ls.amount_from AND ls.amount_to
                    AND MONTHS_BETWEEN(pc.end_date, pc.start_date) / 12 BETWEEN ls.term_ins_from AND
                        ls.term_ins_to
                    AND ls.k_non_med IS NOT NULL
                    AND rownum = 1) AS ep_non_med_order
               ,pc.parent_cover_rsbu_id
               ,pc.parent_cover_ifrs_id
               ,cn_pol_insurer.resident_flag AS is_assured_resident
               ,aa.work_group_id
           FROM ins.p_cover                         pc
               ,ins.as_assured                      aa
               ,ins.as_asset                        se
               ,ins.status_hist                     sh
               ,ins.t_prod_line_option              plo
               ,ins.t_product_line                  pl
               ,ins.t_lob_line                      ll
               ,ins.t_insurance_group               ig
               ,ins.ven_cn_person                   cn_pol_insurer
               ,ins.t_product_line_type             tplt
               ,ins_dwh.reserves_vs_profit_cover_ag ca
          WHERE /*pc.start_date                   <= ins_dwh.pkg_reserves_vs_profit.get_report_date
                                        and */
          pc.as_asset_id = aa.as_assured_id
       AND se.as_asset_id = aa.as_assured_id
       AND pc.status_hist_id = sh.status_hist_id
       AND pc.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.t_lob_line_id = ll.t_lob_line_id
       AND ll.insurance_group_id = ig.t_insurance_group_id
       AND cn_pol_insurer.contact_id = aa.assured_contact_id
       AND pl.product_line_type_id = tplt.product_line_type_id
       AND ca.p_policy_id = se.p_policy_id
       AND ca.t_prod_line_option_id = plo.id
       AND (plo.brief IS NULL OR plo.brief != 'NonInsuranceClaims')
       AND se.p_policy_id IN (SELECT ph.policy_id
                               FROM ins.p_pol_header ph
                                   ,ins.p_policy     pp
                                   ,ins.t_product    pr
                              WHERE ph.product_id = pr.product_id
                                AND ph.policy_id = pp.policy_id)) mn
  LEFT OUTER JOIN ins_dwh.reserves_vs_profit_trans_ag tr
    ON mn.p_asset_header_id = tr.p_asset_header_id
   AND mn.t_prod_line_option_id = tr.t_prod_line_option_id;
