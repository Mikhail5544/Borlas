create or replace force view v_cancel_payment_ad as
select agh.num,
       c.obj_name_orig
from ven_ag_contract_header agh,
     ven_ag_bank_props bpr,
     contact c
where agh.ag_contract_header_id = bpr.ag_contract_header_id
      and agh.agent_id = c.contact_id
      and doc.get_doc_status_brief(agh.ag_contract_header_id) NOT IN ('CANCEL','BREAK','PROJECT')
MINUS
select agh.num,
       c.obj_name_orig
from ven_ag_contract_header agh,
     ven_ag_bank_props bpr,
     contact c
where agh.ag_contract_header_id = bpr.ag_contract_header_id
      and agh.agent_id = c.contact_id
      and bpr.enable = 1
      and doc.get_doc_status_brief(agh.ag_contract_header_id) NOT IN ('CANCEL','BREAK','PROJECT');

