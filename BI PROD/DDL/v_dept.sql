create or replace force view v_dept as
select d.department_id, 
       --decode(lag(q.org_name,1)over(order by q.rn, d.name),q.org_name,null,q.org_name) org_name, 
       q.org_name,
       d.name from
(select organisation_tree_id,
       lpad(name, length(name) + 2 * (level - 1), ' ') org_name,
       rownum rn
  from organisation_tree
 start with parent_id is null
connect by prior organisation_tree_id = parent_id
 order siblings by name) q, department d
 where d.org_tree_id(+)=q.organisation_tree_id
 order by q.rn, d.name
;

