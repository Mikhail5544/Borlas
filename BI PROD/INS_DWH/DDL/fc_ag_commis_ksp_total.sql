CREATE MATERIALIZED VIEW INS_DWH.FC_AG_COMMIS_KSP_TOTAL
REFRESH COMPLETE ON DEMAND
AS
SELECT DISTINCT
       arh.date_begin,
       cn.obj_name_orig "agent",
       ins.doc.get_doc_status_name(ach.ag_contract_header_id) status,
       aca.category_name agent_CAT,
       dep.NAME agency,
       LAST_VALUE(apw.ag_ksp) OVER (PARTITION BY arh.ag_roll_header_id, ach.ag_contract_header_id ORDER BY ar.num),
       cn_l.obj_name_orig agent_leader,
       aca_l.category_name leader_cat,
       dep_l.NAME leader_agency
  FROM ins.ag_roll_header arh,
       ins.ag_roll_type art,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_contract_header ach,
       ins.contact cn,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.ag_agent_tree aat,
       ins.ag_contract_header ach_l,
       ins.contact cn_l,
       ins.ag_contract ac_l,
       ins.ag_category_agent aca_l,
       ins.department dep_l
 WHERE arh.ag_roll_type_id = art.ag_roll_type_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND art.brief IN ('OAV_0510','MnD_PREM')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ach.agent_id = cn.contact_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.category_id = aca.ag_category_agent_id
   and arh.date_end between aat.date_begin and aat.date_end
   AND ach.ag_contract_header_id = aat.ag_contract_header_id
   AND aat.ag_parent_header_id =  ach_l.ag_contract_header_id (+)
   AND ach_l.ag_contract_header_id = ac_l.contract_id (+)
   AND ac_l.category_id = aca_l.ag_category_agent_id (+)
   AND ach_l.agent_id = cn_l.contact_id (+)
   AND ac_l.agency_id = dep_l.department_id (+)
   AND (arh.date_end BETWEEN ac_l.date_begin AND ac_l.date_end
       OR ac_l.contract_id IS NULL);

