CREATE OR REPLACE VIEW INS_DWH.V_COMMISSION_SMEAR_OAV_BANK AS
SELECT *
  FROM (SELECT ar.num_vedom
      ,ar.ver_vedom
      ,el.policy_header_id
      ,pp.pol_ser
      ,pp.pol_num
      ,ph.product_id
      ,pr.description product_name
      ,el.prod_line_option_id AS tplo_id
              ,(SELECT opt.description
                  FROM ins.t_prod_line_option opt
                 WHERE opt.id = el.prod_line_option_id) tplo_name
      ,(SELECT decode(ig.life_property, 1, 'Жизнь', 0, 'НС', 'Не определен')
          FROM ins.t_product_line    pl
              ,ins.t_insurance_group ig
         WHERE pl.id = el.product_line_id
           AND pl.insurance_group_id = ig.t_insurance_group_id) life_property
      ,ph.policy_id AS active_policy_id
      ,el.ag_contract_header_id
      ,ch.agent_id
      ,dc_ch.num AS agent_num
      ,co.obj_name_orig AS agent_name
      ,NULL category_name -- Пусто
      ,NULL agent_state -- Пусто
      ,'Расчет размера АВ для Банков' type_av
      ,el.sav AS vol_rate
      ,CASE
         WHEN ch.storage_ds IS NULL THEN
          el.trans_sum * el.sav
         ELSE
          CASE
                    WHEN ratio_to_report(el.trans_sum * el.sav)
                     over(PARTITION BY el.policy_header_id) IS NOT NULL THEN
                     (el.trans_sum * el.sav) -
                     nvl(ch.storage_ds, 0) * ratio_to_report(el.trans_sum * el.sav)
             over(PARTITION BY el.policy_header_id)
            ELSE
             0
          END
       END AS vol_commiss_msfo
      ,CASE
         WHEN ch.storage_ds IS NULL THEN
          nvl(ar.trans_sum, 0) * nvl(ar.sav, 0)
         WHEN ar.trans_sum IS NOT NULL THEN
          CASE
                    WHEN ratio_to_report(el.trans_sum * el.sav)
                     over(PARTITION BY el.policy_header_id) IS NOT NULL THEN
             (nvl(ar.trans_sum, 0) * nvl(ar.sav, 0)) -
             nvl(ch.storage_ds, 0) * ratio_to_report(el.trans_sum * el.sav)
             over(PARTITION BY el.policy_header_id)
            ELSE
             0
          END
         ELSE
          0
       END AS vol_commiss_rsbu
      ,ar.date_end AS date_calc_borlas
      ,(SELECT ac.plan_date FROM ins.ac_payment ac WHERE ac.payment_id = ar.epg_id) AS date_report
      ,el.p_cover_fee AS fee_cover
      ,'БанкиБрокеры' AS vedom_name
      ,ar.accrual_1c_date AS months_navision
      ,'Расчет размера АВ для Банков' type_prem
      ,NULL date_of_return -- Неизвестно
      , /* Т.к. storage указывается для договора в целом, его надо размазать */CASE
         WHEN ratio_to_report(el.trans_sum * el.sav) over(PARTITION BY el.policy_header_id) != 0 THEN
          nvl(ch.storage_ds, 0) * ratio_to_report(el.trans_sum * el.sav)
          over(PARTITION BY el.policy_header_id)
         ELSE
          0
       END AS storage
      ,CASE
         WHEN ch.rko IS NULL THEN
          NULL
         ELSE
          el.trans_sum * 5.6 / 100
       END AS rko
      ,NULL esn
      ,el.p_cover_id
      ,(SELECT pc.parent_cover_rsbu_id FROM ins.p_cover pc WHERE pc.p_cover_id = el.p_cover_id) AS parent_cover_rsbu_id
      ,(SELECT pc.parent_cover_ifrs_id FROM ins.p_cover pc WHERE pc.p_cover_id = el.p_cover_id) AS parent_cover_ifrs_id
      ,sc.description AS sales_ch_policy
      ,pr.description product_name_policy
      ,tprg.name product_group
            ,CASE
         WHEN ch.storage_ds IS NULL THEN
          el.trans_sum * el.sav
         ELSE
          CASE
                    WHEN ratio_to_report(el.trans_sum * el.sav)
                     over(PARTITION BY el.policy_header_id) IS NOT NULL THEN
                     (el.trans_sum * el.sav) -
                     nvl(ch.storage_ds, 0) * ratio_to_report(el.trans_sum * el.sav)
             over(PARTITION BY el.policy_header_id)
            ELSE
             0
          END
               END - CASE
         WHEN ch.storage_ds IS NULL THEN
          nvl(ar.trans_sum, 0) * nvl(ar.sav, 0)
         WHEN ar.trans_sum IS NOT NULL THEN
          CASE
                    WHEN ratio_to_report(el.trans_sum * el.sav)
                     over(PARTITION BY el.policy_header_id) IS NOT NULL THEN
             (nvl(ar.trans_sum, 0) * nvl(ar.sav, 0)) -
             nvl(ch.storage_ds, 0) * ratio_to_report(el.trans_sum * el.sav)
             over(PARTITION BY el.policy_header_id)
            ELSE
             0
          END
         ELSE
          0
       END AS vol_delta_commis
      ,ar.act_date
      ,ph.start_date AS policy_start_date
      ,ph.ids
      ,CASE
         WHEN ch.storage_ds IS NULL THEN
          el.p_cover_fee * el.sav
         ELSE
          (el.p_cover_fee * el.sav) - (nvl(ch.storage_ds, 0) * el.p_cover_fee * el.sav)
       END AS vol_cover_comiss
      ,dsr.name AS current_pol_status
  FROM (SELECT /*+ NO_MERGE*/
         SUM(el.trans_sum) AS trans_sum
        ,el.policy_header_id
        ,el.policy_id
        ,el.prod_line_option_id
        ,el.product_line_id
        ,el.sav
        ,el.p_cover_id
        ,el.p_cover_fee
        ,el.ag_contract_header_id
          FROM ins.estimated_liabilities el
                 WHERE el.trans_date BETWEEN ins_dwh.pkg_reserves_vs_profit.get_est_limits_date_from AND
                       ins_dwh.pkg_reserves_vs_profit.get_est_limits_date_end
         GROUP BY el.policy_header_id
                 ,el.policy_id
                 ,el.prod_line_option_id
                 ,el.product_line_id
                 ,el.sav
                 ,el.p_cover_id
                 ,el.p_cover_fee
                 ,el.ag_contract_header_id) el
      ,(SELECT /*+ NO_MERGE*/
         SUM(ab.trans_amount) AS trans_sum
        ,ab.p_cover_id
        ,dc_ah.num AS num_vedom
        ,dc_ar.num AS ver_vedom
        ,ab.sav
        ,ar.date_end
        ,ab.epg_id
        ,wa.accrual_1c_date
        ,wa.act_date
          FROM ins.ag_volume_bank       ab
              ,ins.ag_roll              ar
              ,ins.ag_roll_header       ah
              ,ins.document             dc_ah
              ,ins.document             dc_ar
              ,ins.ag_roll_type         rt
              ,ins.ag_perfomed_work_act wa
              ,ins.document             dc_wa
              ,ins.doc_status_ref       dsr_wa
         WHERE ar.date_begin >= ins_dwh.pkg_reserves_vs_profit.get_commiss_date_from
           AND ar.date_end <= ins_dwh.pkg_reserves_vs_profit.get_commiss_date_end
           AND ar.ag_roll_header_id = ah.ag_roll_header_id
           AND ah.ag_roll_type_id = rt.ag_roll_type_id
           AND rt.brief = 'CALC_VOL_BANK'
           AND ar.ag_roll_id = ab.ag_roll_id
           AND ah.ag_roll_header_id = dc_ah.document_id
           AND ar.ag_roll_id = dc_ar.document_id
           AND wa.ag_roll_id = ar.ag_roll_id
           AND wa.ag_contract_header_id = ab.ag_contract_header_id
           AND wa.ag_perfomed_work_act_id = dc_wa.document_id
           AND dc_wa.doc_status_ref_id = dsr_wa.doc_status_ref_id
           AND dsr_wa.brief = 'CONFIRMED'
         GROUP BY ab.p_cover_id
                 ,dc_ah.num
                 ,dc_ar.num
                 ,ab.sav
                 ,ar.date_end
                 ,ab.epg_id
                 ,wa.accrual_1c_date
                 ,wa.act_date) ar
      ,ins.p_pol_header ph
      ,ins.p_policy pp
      ,ins.t_product pr
      ,ins.ag_contract_header ch
      ,ins.document dc_ch
      ,ins.contact co
      ,ins.t_sales_channel sc
      ,ins.t_product_group tprg
      ,ins.document dc
      ,ins.doc_status_ref dsr
 WHERE el.policy_header_id = ph.policy_header_id
   AND el.policy_id = pp.policy_id
   AND ph.product_id = pr.product_id
   AND el.ag_contract_header_id = ch.ag_contract_header_id
   AND ch.ag_contract_header_id = dc_ch.document_id
   AND ch.agent_id = co.contact_id
   AND ph.sales_channel_id = sc.id
   AND pr.t_product_group_id = tprg.t_product_group_id(+)
   AND el.p_cover_id = ar.p_cover_id(+)
   AND pp.policy_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
        UNION ALL -- Удержание
        SELECT de.num_vedom
      ,de.ver_vedom
      ,de.policy_header_id
      ,pp.pol_ser
      ,pp.pol_num
      ,ph.product_id
      ,pr.description product_name
      ,de.prod_line_option_id AS tplo_id
              ,(SELECT opt.description
                  FROM ins.t_prod_line_option opt
                 WHERE opt.id = de.prod_line_option_id) tplo_name
      ,(SELECT decode(ig.life_property, 1, 'Жизнь', 0, 'НС', 'Не определен')
          FROM ins.t_product_line    pl
              ,ins.t_insurance_group ig
         WHERE pl.id = de.product_line_id
           AND pl.insurance_group_id = ig.t_insurance_group_id) life_property
      ,ph.policy_id AS active_policy_id
      ,de.ag_contract_header_id
      ,ch.agent_id
      ,dc_ch.num AS agent_num
      ,co.obj_name_orig AS agent_name
      ,NULL category_name -- Пусто
      ,NULL agent_state -- Пусто
      ,'Расчет размера АВ для Банков' type_av
      ,de.sav AS vol_rate
      ,CASE de.deduction_type
         WHEN 2 THEN
          - CASE
             WHEN ch.storage_ds IS NULL THEN
              de.trans_sum * de.sav
             ELSE
              CASE
                        WHEN ratio_to_report(de.trans_sum * de.sav)
                         over(PARTITION BY de.policy_header_id) IS NOT NULL THEN
                 (de.trans_sum * de.sav) - ch.storage_ds * ratio_to_report(de.trans_sum * de.sav)
                 over(PARTITION BY de.policy_header_id)
                ELSE
                 0
              END
           END
         WHEN 1 THEN
          - (de.trans_sum * de.sav - ratio_to_report(de.trans_sum * de.sav)
             over(PARTITION BY de.policy_header_id) * ch.storage_ds) * CASE
             WHEN de.bank_support IS NOT NULL THEN
              de.bank_support
             ELSE
              1
           END * (de.days_till_decline / de.days_till_end)
       END AS vol_commiss_msfo
      ,CASE de.deduction_type
         WHEN 2 THEN
          - CASE
             WHEN ch.storage_ds IS NULL THEN
              de.trans_sum * de.sav
             ELSE
              CASE
                        WHEN ratio_to_report(de.trans_sum * de.sav)
                         over(PARTITION BY de.policy_header_id) IS NOT NULL THEN
                 (de.trans_sum * de.sav) - ch.storage_ds * ratio_to_report(de.trans_sum * de.sav)
                 over(PARTITION BY de.policy_header_id)
                ELSE
                 0
              END
           END
         WHEN 1 THEN
          - (de.trans_sum * de.sav - ratio_to_report(de.trans_sum * de.sav)
             over(PARTITION BY de.policy_header_id) * ch.storage_ds) * CASE
             WHEN de.bank_support IS NOT NULL THEN
              de.bank_support
             ELSE
              1
           END * (de.days_till_decline / de.days_till_end)
       END AS vol_commiss_rsbu
      ,de.date_end AS date_calc_borlas
      ,NULL AS date_report
      ,de.cover_fee AS fee_cover
      ,'БанкиБрокеры' AS vedom_name
      ,de.accrual_1c_date AS months_navision
      ,'Расчет размера АВ для Банков' type_prem
      ,NULL date_of_return -- Неизвестно
      , /* Т.к. storage указывается для договора в целом, его надо размазать */CASE de.deduction_type
         WHEN 1 THEN
          0
         ELSE
          - CASE
             WHEN ratio_to_report(de.trans_sum * de.sav) over(PARTITION BY de.policy_header_id) != 0 THEN
              nvl(ch.storage_ds, 0) * ratio_to_report(de.trans_amount * de.sav)
              over(PARTITION BY de.policy_header_id)
             ELSE
              0
           END
       END AS storage
      ,CASE de.deduction_type
         WHEN 1 THEN
          0
         ELSE
          - CASE
             WHEN ch.rko IS NULL THEN
              NULL
             ELSE
              de.trans_amount * 5.6 / 100
           END
       END AS rko
      ,NULL esn
      ,de.p_cover_id
      ,(SELECT pc.parent_cover_rsbu_id FROM ins.p_cover pc WHERE pc.p_cover_id = de.p_cover_id) AS parent_cover_rsbu_id
      ,(SELECT pc.parent_cover_ifrs_id FROM ins.p_cover pc WHERE pc.p_cover_id = de.p_cover_id) AS parent_cover_ifrs_id
      ,sc.description AS sales_ch_policy
      ,pr.description product_name_policy
      ,tprg.name product_group
      ,0 AS vol_delta_commis
      ,de.act_date
      ,ph.start_date AS policy_start_date
      ,ph.ids
      ,CASE
         WHEN ch.storage_ds IS NULL THEN
          de.trans_amount * de.sav
         ELSE
          (de.trans_amount * de.sav) - (nvl(ch.storage_ds, 0) * de.trans_amount * de.sav)
       END AS vol_cover_comiss
      ,dsr.name AS current_pol_status
  FROM (SELECT /*+ NO_MERGE*/
         SUM(ab.trans_amount) AS trans_sum
        ,ab.p_cover_id
        ,dc_ah.num AS num_vedom
        ,dc_ar.num AS ver_vedom
        ,ab.sav
        ,ar.date_end
        ,wa.accrual_1c_date
        ,wa.act_date
        ,ab.policy_header_id
        ,ab.ag_contract_header_id
        ,ab.trans_amount
        ,ab.days_till_decline
        ,ab.days_till_end
        ,ab.bank_support
        ,ab.deduction_type
        ,ab.product_line_id
        ,ab.prod_line_option_id
        ,ab.cover_fee
          FROM ins.ag_volume_bank_deduction ab
              ,ins.ag_roll                  ar
              ,ins.ag_roll_header           ah
              ,ins.document                 dc_ah
              ,ins.document                 dc_ar
              ,ins.ag_roll_type             rt
              ,ins.ag_perfomed_work_act     wa
              ,ins.document                 dc_wa
              ,ins.doc_status_ref           dsr_wa
         WHERE ar.date_begin >= ins_dwh.pkg_reserves_vs_profit.get_commiss_date_from
           AND ar.date_end <= ins_dwh.pkg_reserves_vs_profit.get_commiss_date_end
              --AND p_cover_id IN (93322716, 93322717)
              --AND ab.policy_header_id IN (108254858, 107198238, 106519322, 106459633)
           AND ar.ag_roll_header_id = ah.ag_roll_header_id
           AND ah.ag_roll_type_id = rt.ag_roll_type_id
           AND rt.brief = 'CALC_VOL_BANK'
           AND ar.ag_roll_id = ab.ag_roll_id
           AND ah.ag_roll_header_id = dc_ah.document_id
           AND ar.ag_roll_id = dc_ar.document_id
           AND wa.ag_roll_id = ar.ag_roll_id
           AND wa.ag_contract_header_id = ab.ag_contract_header_id
           AND wa.ag_perfomed_work_act_id = dc_wa.document_id
           AND dc_wa.doc_status_ref_id = dsr_wa.doc_status_ref_id
           AND dsr_wa.brief = 'CONFIRMED'
         GROUP BY ab.p_cover_id
                 ,dc_ah.num
                 ,dc_ar.num
                 ,ab.sav
                 ,ar.date_end
                 ,wa.accrual_1c_date
                 ,wa.act_date
                 ,ab.policy_header_id
                 ,ab.ag_contract_header_id
                 ,ab.trans_amount
                 ,ab.days_till_decline
                 ,ab.days_till_end
                 ,ab.bank_support
                 ,ab.deduction_type
                 ,ab.product_line_id
                 ,ab.prod_line_option_id
                 ,ab.cover_fee) de
      ,ins.p_pol_header ph
      ,ins.p_policy pp
      ,ins.t_product pr
      ,ins.ag_contract_header ch
      ,ins.document dc_ch
      ,ins.contact co
      ,ins.t_sales_channel sc
      ,ins.t_product_group tprg
      ,ins.document dc
      ,ins.doc_status_ref dsr
 WHERE de.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = pr.product_id
   AND de.ag_contract_header_id = ch.ag_contract_header_id
   AND ch.ag_contract_header_id = dc_ch.document_id
   AND ch.agent_id = co.contact_id
   AND ph.sales_channel_id = sc.id
   AND pr.t_product_group_id = tprg.t_product_group_id(+)
   AND pp.policy_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id)
 WHERE (num_vedom = ins_dwh.pkg_reserves_vs_profit.get_commiss_num_vedom OR
       ins_dwh.pkg_reserves_vs_profit.get_commiss_num_vedom IS NULL)
   AND (ag_contract_header_id = ins_dwh.pkg_reserves_vs_profit.get_commiss_ag_con_header_id OR
       ins_dwh.pkg_reserves_vs_profit.get_commiss_ag_con_header_id IS NULL);
