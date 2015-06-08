create or replace force view v_right_menu_wiz as
select q2.main_menu_id,
       q2.name
  from (select mm.main_menu_id,
               trim(substr(sys_connect_by_path(replace(name,'.','_'), '.'), 2)) name
          from main_menu mm
         start with mm.parent_id is null
        connect by prior mm.main_menu_id = mm.parent_id) q2,
       (select right_obj_id, sr.name, sr.brief
          from safety_right sr, safety_right_type srt
         where srt.brief = 'MENU'
           and srt.safety_right_type_id = sr.safety_right_type_id) q1
 where q2.main_menu_id = q1.right_obj_id(+)
   and q1.right_obj_id is null;

