CREATE OR REPLACE VIEW V_SMEARING_PREM AS
SELECT arh.num AS num_vedom
      ,ar.num ver_vedom
      ,ph.policy_header_id
      ,pp.pol_ser
      ,pp.pol_num
      ,tp.product_id
      ,tp.description AS product_name
      ,tplo.id AS tplo_id
      ,tplo.description AS tplo_name
      ,decode(ig.life_property, 1, 'Жизнь', 0, 'НС') AS life_property
      ,ph.policy_id AS active_policy_id
      ,ach.ag_contract_header_id
      ,ach.agent_id
      ,ach.num AS agent_num
      ,c_ach.obj_name_orig AS agent_name
      ,aca.category_name AS category_name
      ,NULL AS agent_state
      ,art.name AS type_av
      ,apv.vol_rate AS vol_rate
      ,apv.vol_amount * apv.vol_rate vol_commiss_msfo --ex commis_by_risk
      ,apv.vol_amount * apv.vol_rate vol_commiss_rsbu --ex commis_by_risk
      ,apw.date_calc AS date_calc_borlas
      ,arh.date_end AS date_report
      ,NULL AS date_of_return
      ,0 AS storage
      ,0 AS rko
      ,0 AS esn
      ,NULL AS /*pc.*/ p_cover_id
      ,NULL /*pc.*/ parent_cover_rsbu_id
      ,NULL /*pc.*/ parent_cover_ifrs_id
      ,(SELECT sc.description FROM ins.t_sales_channel sc WHERE sc.id = ph.sales_channel_id) AS sales_ch_policy
      ,tp.description AS product_name_policy
      ,CASE
         WHEN tp.brief != 'GN' THEN
          (SELECT pg.name
             FROM ins.t_product_group pg
            WHERE pg.t_product_group_id = tp.t_product_group_id)
         ELSE
          CASE
            WHEN sc.brief = 'BANK' THEN
             'Group Credit life'
            WHEN EXISTS (SELECT NULL
                    FROM ins.p_policy           pp
                        ,ins.as_asset           aa
                        ,ins.p_cover            pc
                        ,ins.t_prod_line_option plo
                        ,ins.t_product_line     pl
                        ,ins.t_lob_line         ll
                   WHERE pp.pol_header_id = ph.policy_header_id
                     AND pp.policy_id = aa.p_policy_id
                     AND aa.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = plo.id
                     AND plo.product_line_id = pl.id
                     AND pp.policy_id = pp.policy_id
                     AND ll.t_lob_line_id = pl.t_lob_line_id
                     AND ll.description IN
                         ('Программа №1 Смешанное страхование жизни'
                         ,'Программа №4 Дожитие с возвратом взносов в случае смерти')) THEN
             'Group END'
            ELSE
             'Group Term/PA'
          END
       END AS product_group
      ,0 AS vol_delta_commis -- т.к. суммы равны
      ,NULL AS act_date
      ,ph.start_date AS policy_start_date
      ,ph.ids
      ,NULL /*pc.fee * apv.vol_rate*/ AS vol_cover_comiss
      ,(SELECT dsr.name
          FROM document       dcp
              ,doc_status_ref dsr
         WHERE dcp.document_id = pp.policy_id
           AND dcp.doc_status_ref_id = dsr.doc_status_ref_id) AS current_pol_status
      ,NULL /*pc.fee*/ AS fee_cover
  FROM ins.ven_ag_roll_header     arh
      ,ins.ven_ag_roll            ar
      ,ins.ag_roll_type           arot
      ,ins.ag_perfomed_work_act   apw
      ,ins.ag_perfom_work_det     apd
      ,ins.ag_rate_type           art
      ,ins.ag_perf_work_vol       apv
      ,ins.ag_volume              av
      ,ins.ag_volume_type         avt
      ,ins.p_pol_header           ph
      ,ins.p_policy               pp
      ,ins.t_product              tp
      ,ins.t_prod_line_option     tplo
      ,ins.t_product_line         pl
      ,ins.t_lob_line             ll
      ,ins.t_insurance_group      ig
      ,ins.ven_ag_contract_header ach
      ,ins.ag_contract            ac
      ,ins.ag_category_agent      aca
      ,ins.contact                c_ach
      ,t_sales_channel            sc
--,ins.p_cover                pc
 WHERE 1 = 1
      /*AND arh.num = '000389'
      AND ar.num = 1*/
   AND arh.num = lpad((SELECT r.param_value
                        FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'smear_prem'
                         AND r.param_name = 'num_ved')
                     ,6
                     ,'0')
   AND ar.num = (SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'smear_prem'
                    AND r.param_name = 'ver_ved')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND arh.ag_roll_type_id = arot.ag_roll_type_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND avt.brief <> 'INFO'
   AND av.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND av.t_prod_line_option_id = tplo.id
   AND pl.id = tplo.product_line_id
   AND pl.t_lob_line_id = ll.t_lob_line_id
   AND ll.insurance_group_id = ig.t_insurance_group_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND ach.agent_id = c_ach.contact_id
   AND ach.t_sales_channel_id = sc.id
--AND av.p_cover_id = pc.p_cover_id
/*Размазка за достижение уровня, КСП, Индивидуальный план, Премия за достижения KPI 3*/
UNION ALL
SELECT v_num header_num
      ,r_num ar_num
      ,policy_header_id
      ,pol_ser
      ,pol_num
      ,product_id
      ,product_name_policy
      ,tplo_id
       ,tplo_desc
       ,life_prop
       ,active_p_policy_id
       ,ag_contract_header_id
       ,agent_id
       ,ad_num "Номер АД"
       ,ag_fio "Агент ФИО"
       ,ag_cat
       ,NULL
       ,av_type
       ,(CASE
         WHEN av_type IN ('Премия за достижение уровня') THEN
          prem_sum / decode(SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id)
                           ,0
                           ,1
                           ,SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id))
         WHEN av_type = 'Премия за достижения KPI 3 (план по ОПС)' THEN
          prem_sum / ((COUNT(*) over(PARTITION BY ag_perfom_work_det_id)) * 500)
         ELSE
          NULL
       END) "Ставка"
       ,prem_sum *
       (vol_amount / decode(SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id)
                           ,0
                           ,1
                           ,SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id))) vol_commiss_msfo
       ,prem_sum *
       (vol_amount / decode(SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id)
                           ,0
                           ,1
                           ,SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id))) vol_commiss_rsbu
       ,date_of_calc "Дата расчета"
       ,report_date "Отчетный период"
       
       ,NULL AS date_of_return
       ,0 AS storage
       ,0 AS rko
       ,0 AS esn
       ,vol.p_cover_id
       ,vol.parent_cover_rsbu_id
       ,vol.parent_cover_ifrs_id
       ,(SELECT sc.description FROM ins.t_sales_channel sc WHERE sc.id = vol.sales_channel_id) AS sales_ch_policy
       ,vol.product_name_policy
       ,vol.product_group
       ,0 AS vol_delta_commis -- т.к. суммы равны
       ,NULL AS act_date
       ,vol.start_date AS policy_start_date
       ,ids
       ,vol.fee * (CASE
         WHEN av_type IN ('Премия за достижение уровня') THEN
          prem_sum / decode(SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id)
                           ,0
                           ,1
                           ,SUM(vol_amount) over(PARTITION BY ag_perfom_work_det_id))
         WHEN av_type = 'Премия за достижения KPI 3 (план по ОПС)' THEN
          prem_sum / ((COUNT(*) over(PARTITION BY ag_perfom_work_det_id)) * 500)
         ELSE
          NULL
       END) AS vol_cover_comiss
       ,(SELECT dsr.name
          FROM document       dcp
              ,doc_status_ref dsr
         WHERE dcp.document_id = vol.policy_id
           AND dcp.doc_status_ref_id = dsr.doc_status_ref_id) AS current_pol_status
       ,vol.fee AS fee_cover
  FROM (SELECT arh.num v_num
              ,ar.num r_num
              ,ph.policy_header_id
              ,pp.pol_ser
              ,pp.pol_num
              ,tp.product_id AS product_id
              ,tp.description AS product_name_policy
              ,tp.brief AS product_brief
              ,tplo.id tplo_id
              ,tplo.description tplo_desc
              ,decode(ig.life_property, 1, 'Жизнь', 0, 'НС') life_prop
              ,ph.policy_id active_p_policy_id
              ,ach.ag_contract_header_id
              ,ach.agent_id
              ,ach.num ad_num
              ,c_ach.obj_name_orig ag_fio
              ,aca.category_name ag_cat
              ,art_p.name av_type
              ,CASE
                 WHEN avt.brief = 'INV' THEN
                  av.trans_sum * av.nbv_coef
                 WHEN avt.brief = 'FDep' THEN
                  apv.vol_amount * 2
                 ELSE
                  apv.vol_amount
               END vol_amount
              ,apd_p.summ prem_sum
              ,apd_p.ag_perfom_work_det_id
              ,apw.date_calc date_of_calc
              ,arh.date_end report_date
              ,ph.ids
              ,ph.sales_channel_id
              ,ph.start_date
              ,NULL /*pc.*/ p_cover_id
              ,NULL /*pc.*/ parent_cover_rsbu_id
              ,NULL /*pc.*/ parent_cover_ifrs_id
              ,tp.t_product_group_id
              ,pp.policy_id
              ,NULL /*pc.*/ fee
              ,CASE
                 WHEN tp.brief != 'GN' THEN
                  (SELECT pg.name
                     FROM ins.t_product_group pg
                    WHERE pg.t_product_group_id = tp.t_product_group_id)
                 ELSE
                  CASE
                    WHEN sc.brief = 'BANK' THEN
                     'Group Credit life'
                    WHEN EXISTS (SELECT NULL
                            FROM ins.p_policy           pp
                                ,ins.as_asset           aa
                                ,ins.p_cover            pc
                                ,ins.t_prod_line_option plo
                                ,ins.t_product_line     pl
                                ,ins.t_lob_line         ll
                           WHERE pp.pol_header_id = ph.policy_header_id
                             AND pp.policy_id = aa.p_policy_id
                             AND aa.as_asset_id = pc.as_asset_id
                             AND pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pp.policy_id = pp.policy_id
                             AND ll.t_lob_line_id = pl.t_lob_line_id
                             AND ll.description IN
                                 ('Программа №1 Смешанное страхование жизни'
                                 ,'Программа №4 Дожитие с возвратом взносов в случае смерти')) THEN
                     'Group END'
                    ELSE
                     'Group Term/PA'
                  END
               END AS product_group
          FROM ins.ven_ag_roll_header     arh
              ,ins.ven_ag_roll            ar
              ,ins.ag_roll_type           arot
              ,ins.ag_perfomed_work_act   apw
              ,ins.ag_perfom_work_det     apd
              ,ins.ag_rate_type           art
              ,ins.ag_perf_work_vol       apv
              ,ins.ag_volume              av
              ,ins.ag_volume_type         avt
              ,ins.p_pol_header           ph
              ,ins.p_policy               pp
              ,ins.t_product              tp
              ,ins.t_prod_line_option     tplo
              ,ins.t_product_line         pl
              ,ins.t_lob_line             ll
              ,ins.t_insurance_group      ig
              ,ins.ven_ag_contract_header ach
              ,ins.ag_contract            ac
              ,ins.ag_category_agent      aca
              ,ins.ag_perfom_work_det     apd_p
              ,ins.ag_rate_type           art_p
              ,ins.contact                c_ach
              ,t_sales_channel            sc
        --,ins.p_cover                pc
         WHERE 1 = 1
              /*AND arh.num = '000389'
              AND ar.num = 1*/
           AND arh.num = lpad((SELECT r.param_value
                                FROM ins_dwh.rep_param r
                               WHERE r.rep_name = 'smear_prem'
                                 AND r.param_name = 'num_ved')
                             ,6
                             ,'0')
           AND ar.num = (SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'smear_prem'
                            AND r.param_name = 'ver_ved')
           AND arh.ag_roll_header_id = ar.ag_roll_header_id
           AND arh.ag_roll_type_id = arot.ag_roll_type_id
           AND ar.ag_roll_id = apw.ag_roll_id
           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
           AND apd.ag_rate_type_id = art.ag_rate_type_id
           AND art.brief IN ('WG_0510')
           AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
           AND apv.ag_volume_id = av.ag_volume_id
           AND av.ag_volume_type_id = avt.ag_volume_type_id
           AND avt.brief <> 'INFO'
           AND av.policy_header_id = ph.policy_header_id
           AND ph.policy_id = pp.policy_id
           AND ph.product_id = tp.product_id
           AND av.t_prod_line_option_id = tplo.id
              --AND av.p_cover_id = pc.p_cover_id
           AND pl.id = tplo.product_line_id
           AND pl.t_lob_line_id = ll.t_lob_line_id
           AND ll.insurance_group_id = ig.t_insurance_group_id
           AND ach.ag_contract_header_id = apw.ag_contract_header_id
           AND ac.contract_id = ach.ag_contract_header_id
           AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
           AND ac.category_id = aca.ag_category_agent_id
           AND apd_p.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
           AND apd_p.ag_rate_type_id = art_p.ag_rate_type_id
           AND ach.agent_id = c_ach.contact_id
           AND art_p.brief IN ('LVL_0510')
           AND ach.t_sales_channel_id = sc.id) vol;
