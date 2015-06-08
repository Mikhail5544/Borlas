create or replace force view v_main_menu as
select distinct "MAIN_MENU_ID","PARENT_ID","CODE","NAME","NUM","ICON","DISCO_REP" from
(select mm.*
  from main_menu mm
 where mm.main_menu_id > 0
 start with mm.main_menu_id in
            (select mms.main_menu_id
               from main_menu mms
              where safety.check_right_menu(mms.main_menu_id) = 1)
/*select rsm.main_menu_id            
                                               from v_cur_user_safety cus, rel_safety_menu rsm
                                              where mm.main_menu_id = rsm.main_menu_id
                                                and rsm.sys_safety_id = cus.sys_safety_id*/
connect by mm.main_menu_id = prior mm.parent_id
union all
select mm.*
  from main_menu mm
 where main_menu_id > 0
   and user = ents.get_schema
);

