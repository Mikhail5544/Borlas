CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_SMS_AGENT_AWARD AS
SELECT a."AG_FIO",a."AD_NUM",a."AD_CONTACT",a."LEG_POS",a."RL_LIFE_SUM",a."RL_ACCIDENT_SUM",a."NPF_SUM",a."SALES_CH",a."AGENCY",a."ROLL_HEAD_NUM",
       (SELECT wmsys.wm_concat(tp.telephone_prefix||NVL2(tp.telephone_prefix, ' ', '')||tp.telephone_number)
         FROM ins.cn_contact_telephone tp,
              ins.t_telephone_type tt
        WHERE tp.contact_id = a.ad_contact
          AND tt.ID = tp.telephone_type
          AND tt.brief = 'CONT') cont_phone,
       (SELECT wmsys.wm_concat(tp.telephone_prefix||NVL2(tp.telephone_prefix, ' ', '')||tp.telephone_number)
         FROM ins.cn_contact_telephone tp,
              ins.t_telephone_type tt
        WHERE tp.contact_id = a.ad_contact
          AND tt.ID = tp.telephone_type
          AND tt.brief = 'MOBIL') mob_phone,
       (SELECT wmsys.wm_concat(tp.telephone_prefix||NVL2(tp.telephone_prefix, ' ', '')||tp.telephone_number)
         FROM ins.cn_contact_telephone tp,
              ins.t_telephone_type tt
        WHERE tp.contact_id = a.ad_contact
          AND tt.ID = tp.telephone_type
          AND tt.brief = 'PERS') pers_phone
FROM
(
SELECT cn.obj_name_orig AG_fio,
       ach.num ad_num,
       cn.contact_id ad_contact,
       tct.DESCRIPTION leg_pos,
       SUM(CASE WHEN avt.brief = 'RL' THEN
           CASE WHEN ti.life_property = 1 THEN apv.vol_amount*apv.vol_rate ELSE 0 END ELSE 0 END) RL_LIFE_sum,

       SUM(CASE WHEN avt.brief = 'RL' THEN
           CASE WHEN ti.life_property = 0 THEN apv.vol_amount*apv.vol_rate ELSE 0 END ELSE 0 END) RL_ACCIDENT_sum,

       SUM(CASE WHEN avt.brief = 'NPF' THEN apv.vol_amount*apv.vol_rate ELSE 0 END) NPF_sum,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       arh.num roll_head_num
      -- ar.num roll_num
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.t_prod_line_option tplo,
       ins.t_product_line tpl,
       ins.t_insurance_group ti,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ag_contract ac,
       ins.t_sales_channel ts,
       ins.department dep,
       ins.contact cn,
       ins.t_contact_type tct
 WHERE 1=1
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.t_prod_line_option_id = tplo.ID (+)
   AND tplo.product_line_id = tpl.ID (+)
   AND tpl.insurance_group_id = ti.t_insurance_group_id (+)
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.leg_pos = tct.ID
   AND ach.t_sales_channel_id = ts.ID
   AND ach.agent_id = cn.contact_id
 GROUP BY cn.obj_name_orig,
       ach.num,
       cn.contact_id,
       tct.DESCRIPTION,
       ts.DESCRIPTION,
       dep.NAME,
       arh.num,
       ar.num
       ) a
;

