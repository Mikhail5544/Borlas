CREATE OR REPLACE VIEW INS.V_AG_PERFOMED_WORK_ACT AS
SELECT apa.AG_PERFOMED_WORK_ACT_ID AS AG_PERFOMED_WORK_ACT_ID,
       apa.AG_ROLL_ID AS AG_ROLL_ID,
       apa.delta AS DELTA,
       concat(concat(ach.num, '/'), c.obj_name_orig) AS AGENT_DOG,
       d.NAME AS AGENCY,
       asa.NAME AS STATUS,
       st.NAME AS SGP_TYPE,
       round(nvl(agp.SGP_SUM, apa.sgp1),2) AS SGP_SUM,
       round(apa.SUM,2) AS PREM_SUM,
       apa.DATE_CALC AS DATE_CALC,
       dsr.NAME AS ACT_STATUS_NAME,
       ds.USER_NAME AS STATUS_USER_NAME,
       ds.START_DATE AS STATUS_START_DATE,
       ach.date_begin AS DATE_BEGIN_AD,
       ach.num NUM_AGENT,
       c.obj_name_orig FIO_AGENT
  FROM ag_perfomed_work_act apa
  JOIN ins.ven_ag_contract_header ach on ach.ag_contract_header_id = apa.ag_contract_header_id
  JOIN ins.contact c on c.contact_id = ach.agent_id
  LEFT JOIN ven_ag_sgp agp on agp.ag_roll_id = apa.ag_roll_id AND agp.ag_contract_header_id = apa.ag_contract_header_id
  LEFT JOIN ven_ag_stat_agent asa on asa.ag_stat_agent_id = agp.status_id
  LEFT JOIN ven_t_sgp_type st on st.t_sgp_type_id = agp.sgp_type_id
  JOIN ven_department d on d.department_id = ach.agency_id
  LEFT JOIN ven_doc_status ds on ds.doc_status_id = doc.get_last_doc_status_id(apa.AG_PERFOMED_WORK_ACT_ID)
  LEFT JOIN ven_doc_status_ref dsr on dsr.DOC_STATUS_REF_ID = ds.DOC_STATUS_REF_ID;
grant select on INS.V_AG_PERFOMED_WORK_ACT to INS_READ;

