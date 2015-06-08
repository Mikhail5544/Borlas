create or replace force view v_rel_safety_menu2 as
select safetyname,
       manuname,
       sys_safety_id,
       main_menu_id,
       cast(decode(access_level,
                   null,
                   'Xsafety_nonegf',
                   0,
                   '0safety_readongf',
                   1,
                   '1safety_fullgf') as varchar2(30)) access_icon,
       access_level
  from (select s.name safetyname,
               m.name manuname,
               s.sys_safety_id sys_safety_id,
               m.main_menu_id main_menu_id,
               (select decode(srr.add_flag,1,1,0,0,null)
                   from safety_right_role srr
                  where srr.safety_right_id = srg.safety_right_id
                    and srr.role_id = s.sys_safety_id)
               /*(select r.access_level
                                 from rel_safety_menu r
                                where r.main_menu_id = m.main_menu_id
                                  and r.sys_safety_id = s.sys_safety_id)*/ access_level
          from sys_safety        s,
               main_menu         m,
               sys_role          sr,
               safety_right      srg,
               safety_right_type srt
         where m.main_menu_id >= 0
           and sr.sys_role_id = s.sys_safety_id
           and srg.safety_right_type_id = srt.safety_right_type_id
           and srt.brief = 'MENU'
           and m.main_menu_id = srg.right_obj_id);

