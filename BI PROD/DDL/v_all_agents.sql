create or replace force view v_all_agents as
select agh.num||' '||c.obj_name_orig agent_name
from ins.ven_ag_contract_header agh,
     ins.contact c
where agh.agent_id = c.contact_id;

