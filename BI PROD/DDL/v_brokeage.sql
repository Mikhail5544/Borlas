create or replace force view v_brokeage as
select c.contact_id,
       c.obj_name_orig contact_name,
       d.department_id,
       d.name department_name,
       ot.organisation_tree_id,
       ot.name organisation_name
  from employee_hist eh, employee e, contact c, department d, organisation_tree ot
 where e.employee_id = eh.employee_id
   and eh.date_hist =
       (select max(ehm.date_hist)
          from employee_hist ehm
         where ehm.employee_id = e.employee_id)
   and eh.is_brokeage = 1
   and c.contact_id = e.contact_id
   and eh.department_id = d.department_id
   and d.org_tree_id = ot.organisation_tree_id;

