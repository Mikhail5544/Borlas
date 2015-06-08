create or replace view v_reestr_prem as
SELECT aca.category_name ag_cat,
       cn.obj_name_orig AG_fio,
       ach.num ad_num,
       cn.contact_id ad_contact,
       tct.DESCRIPTION leg_pos,
       SUM(apd.summ) prem_sum,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ven_ag_contract_header ach,
       ag_contract ac,
       t_sales_channel ts,
       department dep,
       contact cn,
       t_contact_type tct,
       ag_category_agent aca
 WHERE 1=1
   AND arh.num = LPAD((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'reestr_prem'
                         AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'reestr_prem'
                   AND r.param_name = 'ver_ved')
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
       dep.NAME;
/
GRANT SELECT ON v_reestr_prem to INS_EUL;
       