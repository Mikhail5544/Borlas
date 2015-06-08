create or replace force view v_dept_tree as
select id,
       lpad(description, length(description) + 2 * (level - 1), ' ') name,
       description
  from (select ct.id, ct.parent_id, d.description
          from ven_t_company_tree ct, ven_t_department d
         where ct.department_id = d.id)
 start with parent_id is null
connect by prior id = parent_id
 order siblings by description;

