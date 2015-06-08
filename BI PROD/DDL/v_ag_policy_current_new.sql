create or replace view v_ag_policy_current_new as
select  pr.description description
, pp.num num
, dc.P_POLICY_AGENT_DOC_ID
, dc.policy_header_id
, dc.AG_CONTRACT_HEADER_ID
, dc.DATE_begin
, dc.DATE_END
, cn.obj_name_orig INSURER_NAME
from P_POLICY_AGENT_DOC dc
     , P_POL_HEADER PH
     , VEN_P_POLICY PP
     , T_PRODUCT PR
     , contact cn
where   dc.POLICY_HEADER_ID = PH.POLICY_HEADER_ID
        and PP.policy_id = ph.policy_id
        and PH.PRODUCT_ID = PR.PRODUCT_ID
        and cn.contact_id = pkg_policy.get_policy_contact(ph.policy_id,'Страхователь')
        and doc.get_doc_status_brief(dc.p_policy_agent_doc_id) <> 'ERROR'
