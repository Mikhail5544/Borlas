create or replace view v_t_tap_employee as
select rh.t_roo_header_id
      ,co.obj_name_orig          as user_name
      ,su.sys_user_name          as login_name
  from ven_t_roo_header   rh
      ,ven_t_roo_employee em
      ,ven_sys_user       su
      ,ven_employee       ee
      ,contact            co
 where rh.last_roo_id = em.t_roo_id
   and em.sys_user_id = su.sys_user_id
   and su.employee_id = ee.employee_id
   and ee.contact_id  = co.contact_id
   and em.end_date    = pkg_roo.get_default_end_date;
