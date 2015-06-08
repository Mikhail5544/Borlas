CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_SMS_MNGR_AWARD AS
SELECT a."AG_CAT",a."AG_FIO",a."AD_NUM",a."AD_CONTACT",a."LEG_POS",a."PREM_SUM",a."SALES_CH",a."AGENCY",a."NUM",
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
SELECT aca.category_name ag_cat,
       cn.obj_name_orig AG_fio,
       ach.num ad_num,
       cn.contact_id ad_contact,
       tct.DESCRIPTION leg_pos,
       SUM(apd.summ) prem_sum,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       arh.num
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ven_ag_contract_header ach,
       ins.ag_contract ac,
       ins.t_sales_channel ts,
       ins.department dep,
       ins.contact cn,
       ins.t_contact_type tct,
       ins.ag_category_agent aca
 WHERE 1=1
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.leg_pos = tct.ID
   AND ach.t_sales_channel_id = ts.ID
   AND ach.agent_id = cn.contact_id
   AND ac.category_id = aca.ag_category_agent_id
 GROUP BY
       aca.category_name,
       cn.obj_name_orig,
       ach.num,
       cn.contact_id,
       tct.DESCRIPTION,
       ts.DESCRIPTION,
       dep.NAME,
       arh.num
) a;

