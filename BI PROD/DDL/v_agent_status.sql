CREATE OR REPLACE FORCE VIEW V_AGENT_STATUS AS
SELECT cn.obj_name_orig "ФИО агента",
       ach.num "Номер АД",
       ach.date_begin "Дата начала АД",
       doc.get_doc_status_name(ach.ag_contract_header_id) "Статус АД",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агентство",
       ash.stat_date "Дата статуса агента",
       asa.NAME "Статус агента",
       ash.num "Номер статуса"
  FROM ag_stat_agent asa,
       ag_stat_hist ash,
       ven_ag_contract_header ach,
       contact cn
 WHERE cn.contact_id = ach.agent_id
   AND ach.ag_contract_header_id = ash.ag_contract_header_id
   AND ash.AG_STAT_AGENT_ID = asa.AG_STAT_AGENT_ID
   AND ash.stat_date>= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'agent_status' and param_name = 'start_date');

