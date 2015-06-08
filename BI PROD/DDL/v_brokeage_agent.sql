create or replace force view v_brokeage_agent as
select contact_id, obj_name_orig contact_name
  from (select c.ent_id, c.contact_id, c.obj_name_orig
          from employee_hist eh, employee e, contact c
         where e.employee_id = eh.employee_id
           and eh.date_hist =
               (select max(ehm.date_hist)
                  from employee_hist ehm
                 where ehm.employee_id = e.employee_id)
           and eh.is_brokeage = 1
           and c.contact_id = e.contact_id
        union
        select c.ent_id, c.contact_id, c.obj_name_orig
          from t_contact_role tcr, contact c, cn_contact_role ccr
         where tcr.description = 'Агент'
           and ccr.role_id = tcr.id
           and ccr.contact_id = c.contact_id);

