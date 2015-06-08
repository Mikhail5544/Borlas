create or replace force view v_org_dept_role as
select odr.org_dept_role_id,
       ot.organisation_tree_id,
       dr.t_dept_role_id,
       odr.department_id,
       ot.name organisation_name,
       dr.name role_name,
       d.name department_name
  from organisation_tree ot
 inner join t_dept_role dr on 1 = 1 left join org_dept_role odr on
 ot.organisation_tree_id = odr.organisation_id
                          and dr.t_dept_role_id = odr.t_dept_role_id left join
 department d on
 odr.department_id = d.department_id;

