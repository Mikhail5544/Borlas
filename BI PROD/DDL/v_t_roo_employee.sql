create or replace view v_t_roo_employee as
select em.t_roo_employee_id
      ,em.t_roo_id
      ,su.sys_user_id
      ,co.obj_name_orig          as user_name
      ,su.sys_user_name as login_name
      ,em.begin_date
      ,nullif(em.end_date,pkg_tac.get_default_end_date) as end_date
  from ven_t_roo_employee em
      ,ven_sys_user       su
      --,ven_employee       ee --Чирков 230748: Исправление по заявке 207619
      ,contact            co
 where em.sys_user_id = su.sys_user_id
   --Чирков 230748: Исправление по заявке 207619
   --and su.employee_id = ee.employee_id   
   --and ee.contact_id  = co.contact_id
   --Чирков добавил 230748: Исправление по заявке 207619
   and su.contact_id = co.contact_id;
   --
