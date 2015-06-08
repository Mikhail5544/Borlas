CREATE OR REPLACE VIEW V_REESTR_OAV AS
SELECT cn.obj_name_orig ag_fio
      ,ach.num ad_num
      ,cn.contact_id ad_contact
      ,tct.description leg_pos
      ,SUM(CASE
             WHEN avt.brief IN ('RL', 'FDep') THEN
              CASE
                WHEN ti.life_property = 1 THEN
                 apv.vol_amount * apv.vol_rate
                ELSE
                 0
              END
             ELSE
              0
           END) rl_life_sum
      ,SUM(CASE
             WHEN avt.brief = 'INV' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) rl_inv_sum
      ,SUM(CASE
             WHEN avt.brief IN ('RL', 'FDep') THEN
              CASE
                WHEN ti.life_property = 0 THEN
                 apv.vol_amount * apv.vol_rate
                ELSE
                 0
              END
             ELSE
              0
           END) rl_accident_sum
      ,SUM(CASE
             WHEN avt.brief = 'NPF' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) npf_sum
      ,SUM(CASE
             WHEN avt.brief = 'NPF02' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) npf02_sum
      ,SUM(CASE
             WHEN avt.brief = 'SOFI' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) sofi_sum
      ,SUM(CASE
             WHEN avt.brief = 'AVCP' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) avcp_sum
      ,SUM(CASE
             WHEN rt.brief = 'CONV_SHEET' THEN
              apv.vol_amount * apv.vol_rate
             ELSE
              0
           END) activity_meetings_sum
      ,ts.description sales_ch
      ,dep.name agency
  FROM ins.ven_ag_roll_header     arh
      ,ins.ven_ag_roll            ar
      ,ins.ag_perfomed_work_act   apw
      ,ins.ag_perfom_work_det     apd
      ,ins.ag_perf_work_vol       apv
      ,ins.ag_volume              av
      ,ins.t_prod_line_option     tplo
      ,ins.t_product_line         tpl
      ,ins.t_insurance_group      ti
      ,ins.ag_volume_type         avt
      ,ins.ven_ag_contract_header ach
      ,ins.ag_contract            ac
      ,ins.t_sales_channel        ts
      ,ins.department             dep
      ,ins.contact                cn
      ,ins.t_contact_type         tct
      ,ins.ag_rate_type           rt
 WHERE 1 = 1
   AND arh.num = lpad((SELECT r.param_value
                        FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'reestr_oav'
                         AND r.param_name = 'num_ved')
                     ,6
                     ,'0')
   AND ar.num = (SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'reestr_oav'
                    AND r.param_name = 'ver_ved')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.t_prod_line_option_id = tplo.id(+)
   AND tplo.product_line_id = tpl.id(+)
   AND tpl.insurance_group_id = ti.t_insurance_group_id(+)
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.leg_pos = tct.id
   AND ach.t_sales_channel_id = ts.id
   AND ach.agent_id = cn.contact_id
   AND apd.ag_rate_type_id = rt.ag_rate_type_id
 GROUP BY cn.obj_name_orig
         ,ach.num
         ,cn.contact_id
         ,tct.description
         ,ts.description
         ,dep.name;
