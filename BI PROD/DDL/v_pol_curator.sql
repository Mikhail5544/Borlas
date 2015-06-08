create or replace force view v_pol_curator as
select pc.policy_id,
       pc.contact_id,
       c.obj_name_orig contact_name,
       eh.department_id
  from p_policy_contact pc,
       t_contact_pol_role cpr,
       ven_contact c,
       employee e,
       employee_hist eh
 where cpr.brief = 'Куратор'
   and cpr.id = pc.contact_policy_role_id
   and c.contact_id = pc.contact_id
   and e.contact_id = c.contact_id
   and eh.employee_id = e.employee_id
   and eh.date_hist = (select max(ehlast.date_hist)
                         from employee_hist ehlast
                        where ehlast.employee_id = e.employee_id
                          and ehlast.date_hist <= sysdate
                          and ehlast.is_kicked = 0);

