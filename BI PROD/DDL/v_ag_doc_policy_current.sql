CREATE OR REPLACE FORCE VIEW V_AG_DOC_POLICY_CURRENT AS
select
  pr.description description
, pp.pol_num num
, pad.p_policy_agent_doc_id
, pad.policy_header_id
, ph.policy_id
, pad.AG_CONTRACT_HEADER_ID
, pad.date_begin
, pp.end_date date_end--pad.date_end
, rf.doc_status_ref_id
, ent.obj_name(ent.id_by_brief('CONTACT'),pc.contact_id) INSURER_NAME
, rf_pol.name DOC_STATUS_NAME
, (SELECT MAX(poli.decline_date)
   FROM ins.p_policy poli
   WHERE poli.pol_header_id = ph.policy_header_id
   ) decline_date
from ins.P_POLICY_AGENT_DOC PAD
   , ins.P_POL_HEADER PH
   , ins.document dpol
   , ins.doc_status_ref rf_pol
   , ins.P_POLICY PP
   , ins.T_PRODUCT PR
   , ins.P_POLICY_CONTACT PC
   , ins.document d
   , ins.doc_status_ref rf
where pad.p_policy_agent_doc_id = d.document_id
  AND d.doc_status_ref_id = rf.doc_status_ref_id
  AND rf.brief = 'CURRENT'
  and PAD.POLICY_HEADER_ID = PH.POLICY_HEADER_ID
  and PP.policy_id = ph.policy_id
  AND ph.last_ver_id = dpol.document_id
  AND dpol.doc_status_ref_id = rf_pol.doc_status_ref_id
  and PH.PRODUCT_ID = PR.PRODUCT_ID
  and pc.policy_id = ph.policy_id
  and pc.contact_policy_role_id = ent.get_obj_id('t_contact_pol_role','Страхователь')
  /*AND ph.ids = 1910071260*/
;

