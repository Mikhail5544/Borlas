create or replace force view v_dept_agent as
select a.contact_id,
       a.contact_name,
       d.department_id,
       d.name department_name,
       ot.organisation_tree_id,
       ot.name organisation_name
  from v_agent a, dept_agent da, department d, organisation_tree ot
 where da.agent_id = a.contact_id
   and d.department_id = da.department_id
   and d.org_tree_id = ot.organisation_tree_id;

