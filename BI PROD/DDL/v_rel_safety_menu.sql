create or replace force view v_rel_safety_menu as
select safetyname,
       manuname,
       sys_safety_id,
       main_menu_id,
       cast(decode(access_level,
                   null, 'Xsafety_nonegf', 
                   0,    '0safety_readongf', 
                   1,    '1safety_fullgf') as varchar2(30)) access_icon,
       access_level
  from (select s.name safetyname,
               m.name manuname,
               s.sys_safety_id sys_safety_id,
               m.main_menu_id main_menu_id,
               (select r.access_level
                  from rel_safety_menu r
                 where r.main_menu_id = m.main_menu_id
                   and r.sys_safety_id = s.sys_safety_id) access_level
        
          from sys_safety s, main_menu m 
          where m.main_menu_id >= 0 
        );

