create or replace view v_sys_user as
SELECT vsu."SYS_USER_ID"
       ,vsu."ENT_ID"
       ,vsu."FILIAL_ID"
       ,vsu."EXT_ID"
       ,vsu."NAME"
       ,vsu."EMPLOYEE_ID"
       ,vsu."FLAG_ROBOT_PROTECT"
       ,vsu."INCUMBENT"
       ,vsu."LANG_ID"
       ,vsu."SYS_USER_NAME"
       ,vot.name                 organisation_name
       ,vot.organisation_tree_id organisation_id
       ,c.obj_name_orig          employee_name
       ,c.contact_id             contact_id
       ,l.name                   lang_name
  FROM ven_sys_user          vsu
      ,ven_organisation_tree vot
      ,ven_employee          e
      ,contact               c
      ,lang                  l
 WHERE vsu.employee_id = e.employee_id(+)
   AND c.contact_id(+) = vsu.contact_id --Чирков 230748: Исправление по заявке 207619
   AND vot.organisation_tree_id(+) = e.organisation_id
   AND vsu.lang_id = l.lang_id(+);
