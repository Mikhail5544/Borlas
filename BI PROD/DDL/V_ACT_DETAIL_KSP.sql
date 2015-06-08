CREATE OR REPLACE VIEW INS.V_ACT_DETAIL_KSP AS
SELECT apa.AG_PERFOMED_WORK_ACT_ID AS AG_PERFOMED_WORK_ACT_ID,
       apa.AG_ROLL_ID AS AG_ROLL_ID,
       d.num AGENT_NUM,
       c.obj_name_orig AGENT_FIO,
       d.NAME AS AGENCY,
       apa.DATE_CALC AS DATE_CALC,
       ach.date_begin AS DATE_BEGIN_AD,
       art.NAME AS PREM_NAME,
       ROUND(apd.SUMM,2) AS PREM_SUMM
  FROM ins.ag_perfomed_work_act apa
  JOIN ins.ag_contract_header ach on ach.ag_contract_header_id = apa.ag_contract_header_id
  JOIN ins.document d ON (ach.ag_contract_header_id = d.document_id)
  JOIN ins.ag_perfom_work_det apd on (apa.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id)
  JOIN ins.ag_rate_type art on art.ag_rate_type_id = apd.ag_rate_type_id
  JOIN ins.contact c on c.contact_id = ach.agent_id
  JOIN ins.department d on d.department_id = ach.agency_id;
grant select on INS.V_ACT_DETAIL_KSP to INS_READ;