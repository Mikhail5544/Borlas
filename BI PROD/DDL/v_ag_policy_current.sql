create or replace force view v_ag_policy_current as
( select
  0 pr_gen
, pr.description description
, pp.num
, pa.P_POLICY_AGENT_ID
, pa.policy_header_id
, pa.AG_CONTRACT_HEADER_ID
, pa.DATE_START
, pa.DATE_END
, PA.PART_AGENT
, pa.STATUS_ID
, ent.obj_name(ent.id_by_brief('CONTACT'),pc.contact_id) INSURER_NAME
, doc.get_doc_status_name(ph.policy_id) DOC_STATUS_NAME
from VEN_P_POLICY_AGENT PA
   , VEN_P_POL_HEADER PH
   , VEN_P_POLICY PP
   , VEN_T_PRODUCT PR
   , P_POLICY_CONTACT PC
where PA.STATUS_ID=ent.get_obj_id('POLICY_AGENT_STATUS','CURRENT')
  and PA.POLICY_HEADER_ID = PH.POLICY_HEADER_ID
  and PP.policy_id = ph.policy_id
  and PH.PRODUCT_ID = PR.PRODUCT_ID
  and pc.policy_id = ph.policy_id
  and pc.contact_policy_role_id = ent.get_obj_id('t_contact_pol_role','—Ú‡ıÓ‚‡ÚÂÎ¸')
  and exists ( select count(*), policy_header_id
               from p_policy_agent
               where policy_header_id=pa.policy_header_id
               and STATUS_ID=ent.get_obj_id('POLICY_AGENT_STATUS','CURRENT')
               group by policy_header_id
               having count(*)<=1 )
union all
  select
  1 pr_gen
, '√≈Õ≈–¿À‹Õ€… ƒŒ√Œ¬Œ–' description
, gp.num
, pa.P_POLICY_AGENT_ID
, pa.policy_header_id
, pa.AG_CONTRACT_HEADER_ID
, pa.DATE_START
, pa.DATE_END
, PA.PART_AGENT
, pa.STATUS_ID
, ent.obj_name('CONTACT',gp.insurer_id) INSURER_NAME
, doc.get_doc_status_name(gen_policy_id) DOC_STATUS_NAME
from VEN_P_POLICY_AGENT PA , VEN_GEN_POLICY GP
where PA.STATUS_ID=ent.get_obj_id('POLICY_AGENT_STATUS','CURRENT')
  and PA.POLICY_HEADER_ID = GP.gen_policy_id
  and exists ( select count(*), policy_header_id
               from p_policy_agent
               where policy_header_id=pa.policy_header_id
               and STATUS_ID=ent.get_obj_id('POLICY_AGENT_STATUS','CURRENT')
               group by policy_header_id
               having count(*)<=1 )
);

