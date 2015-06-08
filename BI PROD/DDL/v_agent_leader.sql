create or replace force view v_agent_leader as
select distinct
ch_1.ag_contract_header_id parent_h_id
, ch_2.ag_contract_header_id ag_h_id
, ca_4.category_name||':  '||con.obj_name_orig ag_name
, ca_3.ag_category_agent_id parent_cat_id
, ca_4.ag_category_agent_id ag_cat_id
from ven_ag_contract_header ch_1
, ven_ag_contract ac_1
, ven_ag_contract_header ch_2
, ven_ag_contract ac_2
, ven_ag_contract ac_3
, ven_ag_category_agent ca_3
, ven_ag_contract ac_4
, ven_ag_category_agent ca_4
, ven_contact con
where ch_1.ag_contract_header_id = ac_1.contract_id
and ch_2.ag_contract_header_id = ac_2.contract_id
and ac_1.ag_contract_id = ac_2.contract_leader_id
and ch_1.last_ver_id = ac_3.ag_contract_id
and ac_3.category_id= ca_3.ag_category_agent_id
and ch_2.last_ver_id = ac_4.ag_contract_id
and ac_4.category_id= ca_4.ag_category_agent_id
and con.contact_id=ch_2.agent_id;

