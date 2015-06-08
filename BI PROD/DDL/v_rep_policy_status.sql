CREATE OR REPLACE FORCE VIEW V_REP_POLICY_STATUS AS
(
SELECT dep.NAME "Агентство Агента по ДС",
       cn_ag.obj_name_orig "Агент по ДС",
       ph.policy_header_id "ID ДС",
       pp.pol_ser "Серия ДС",
       pp.pol_num "Номер ДС",
       trunc(pp.sign_date, 'dd') "Дата акцепта ДС",
       pp.version_num "Версия ДС",
       dsr.name "Статус версии",
       ds.start_date "Дата статуса",
       ds.change_date "Дата регистрации статуса",
       ach.ag_contract_header_id
  FROM ins.p_pol_header       ph,
       ins.p_policy           pp,
       ins.ag_contract_header ach,
       ins.contact            cn_ag,
       ins.department         dep,
       ins.doc_status         ds,
       ins.doc_status_ref     dsr,
       ins.p_policy_agent     pa
 WHERE ph.policy_header_id = pp.pol_header_id
   AND pp.policy_id = ds.document_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND pp.pol_header_id = pa.policy_header_id
   AND pa.ag_contract_header_id = ach.ag_contract_header_id
   AND pa.date_start <= ds.start_date
   AND pa.date_end > ds.start_date
   AND ach.agent_id = cn_ag.contact_id
   AND ach.agency_id = dep.department_id
   AND pp.sign_date BETWEEN (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'POLICY_ST'
                                AND r.param_name = 'DATE_FROM')
                            AND (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'POLICY_ST'
                                    AND r.param_name = 'DATE_TO')
   AND dep.name IN (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'POLICY_ST'
                       AND r.param_name = 'AGENCY')
--AND     ph.policy_header_id         =   6702981
 --ORDER BY 1,3,5,7,9
 ) ORDER BY 1,3,5,7,9
;

