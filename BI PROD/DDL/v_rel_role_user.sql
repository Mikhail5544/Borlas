create or replace force view v_rel_role_user as
select u.name username,
         r.name rolename,
         u.sys_user_id userid,
         r.sys_role_id roleid,
         nvl2((select rr.rel_role_user_id
                from rel_role_user rr
               where rr.sys_role_id = r.sys_role_id
                 and rr.sys_user_id = u.sys_user_id),
              1,
              0) assigned
    from ven_sys_user u, ven_sys_role r
   order by u.name, r.name;

