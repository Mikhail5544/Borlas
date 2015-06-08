create or replace force view v_department as
select d.department_id, q.name org_name, d.name
from
(select vot.*, rownum rn from v_org_tree vot)q, department d
where d.org_tree_id = q.organisation_tree_id
order by q.rn, d.name;

