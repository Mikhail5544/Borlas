create or replace force view v_agent_tree as
select "AG_CONTRACT_HEADER_ID","AG_CONTRACT_ID","AGENCY_ID","AGENT_ID","AGENT_NAME","NUM","NUM_VER","DATE_BEGIN","DATE_END","STATUS_NAME","CATEGORY_SORT","CATEGORY_NAME","CLASS_NAME","KOD_AGENT","KOD_AGENCY","CONTRACT_LEADER_ID","LEADER_NAME"
 from v_ag_contract_journal v
start with v.contract_leader_id=pkg_agent.get_id
connect by prior v.ag_contract_id=v.contract_leader_id;

