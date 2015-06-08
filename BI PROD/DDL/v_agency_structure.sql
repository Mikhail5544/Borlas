CREATE OR REPLACE FORCE VIEW V_AGENCY_STRUCTURE AS
SELECT 'Филиалы/Агентства' NAME,
       0 id,
       NULL parent_id,
       0 num
  FROM dual

UNION

/*SELECT ent.obj_name(c.ent_id, c.contact_id) NAME,
       c.contact_id id,
       0 parent_id
  FROM ven_contact         c,
       ven_t_contact_role  tcr,
       ven_cn_contact_role ccr
 WHERE tcr.description = 'Агентство'
   AND ccr.role_id = tcr.id
   AND ccr.contact_id = c.contact_id
*/
SELECT dep.name,
       dep.department_id,
       0 parent_id,
       dep.department_id
  FROM Organisation_Tree ot,
       department        dep
 WHERE dep.Org_Tree_Id = ot.organisation_tree_id
   AND ot.parent_id IS NOT NULL


UNION

SELECT (ca.category_name || ': ' || ent.obj_name(co.ent_id, ch.agent_id)) NAME,
       ac.ag_contract_id id,
       (CASE
         WHEN ac.contract_leader_id IS NULL THEN
          ch.agency_id
         ELSE
          ac.contract_leader_id
       END) parent_id,
       ch.agency_id
  FROM ven_ag_contract_header ch,
       ven_ag_contract        ac,
       ven_ag_category_agent  ca,
       contact                co
 WHERE ac.ag_contract_id = pkg_agent_1.get_status_by_date(ac.contract_id,SYSDATE) --.get_status_contr_activ_id(ac.contract_id)
   AND ca.ag_category_agent_id = ac.category_id
   AND ch.ag_contract_header_id = ac.contract_id
   AND co.contact_id = ch.agent_id
;

