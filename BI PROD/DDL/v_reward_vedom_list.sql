CREATE OR REPLACE FORCE VIEW V_REWARD_VEDOM_LIST AS
(
SELECT ach.ag_contract_header_id contract_header_id,
       ach.agent_id,
       c.obj_name_orig ФИО,
       cp.date_of_birth "Дата рождения",
       ach.num "Номер АД",
       ach.agency_id agency_id,
       d.NAME "Агенство",
       arh.date_begin "Дата ведомости",
       decode(agc.leg_pos, 1030, 'ПБОЮЛ', ' ') "Признак ПБЮОЛ",
       SUM(apd.summ) "Сумма всех премий",
       agcc.category_name,
       ts.DESCRIPTION sales_ch
  FROM ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ven_ag_contract_header ach,
       ins.ag_contract agc,
       ins.ag_category_agent agcc,
       ins.contact c,
       ins.cn_person cp,
       ins.department d,
       ins.ag_roll_type art,
       ins.t_sales_channel ts
 WHERE 1 = 1
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND agc.ag_contract_id = ins.pkg_agent.get_status_by_date(ach.ag_contract_header_id, arh.date_end)
   AND agcc.ag_category_agent_id = agc.category_id
   AND c.contact_id = ach.agent_id
   AND cp.contact_id = c.contact_id
   AND ach.t_sales_channel_id = ts.ID
   AND d.department_id = ach.agency_id
   AND arh.ag_roll_type_id = art.ag_roll_type_id
   AND arh.num IN (SELECT rp.param_value
                     FROM ins_dwh.rep_param rp
                    WHERE rp.rep_name = 'REW_VEDOM'
                      AND rp.param_name = 'VEDOM')
   AND ar.num IN (SELECT rp.param_value
                    FROM ins_dwh.rep_param rp
                   WHERE rp.rep_name = 'REW_VEDOM'
                     AND rp.param_name = 'SUBVEDOM')
 GROUP BY
       agcc.category_name,
       c.obj_name_orig,
       ach.num,
       c.contact_id,
       ts.DESCRIPTION,
       d.NAME,
       ach.ag_contract_header_id,
       ach.agent_id,
 cp.date_of_birth ,
 ach.agency_id   ,
 arh.date_begin,
 decode(agc.leg_pos, 1030, 'ПБОЮЛ', ' ')
)

/*SELECT aca.category_name ag_cat,
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
   AND arh.num = '000205'
   AND ar.num = '1'
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
       dep.NAME*/;

