create or replace force view v_agent_polic as
select ph.policy_header_id,
       ac1.ag_contract_header_id ag_contract_hd,
       ac1.agent_id agent_id_1,
       c.obj_name_orig agent_name_1
  from ven_p_pol_header ph, 
       ven_ag_contract_header ac1, 
       ven_p_policy_agent pa,
       ven_policy_agent_status pas,
       contact c
 where ph.policy_header_id=pa.policy_header_id
   and pa.ag_contract_header_id=ac1.ag_contract_header_id
   and pa.status_id=pas.policy_agent_status_id
   and pas.brief='CURRENT'
   and c.contact_id = ac1.agent_id;

