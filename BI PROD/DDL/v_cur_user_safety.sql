create or replace force view v_cur_user_safety as
select su.sys_user_id sys_safety_id, ss.name
  from sys_user su, sys_safety ss
 where su.sys_user_name = user
   and ss.sys_safety_id = su.sys_user_id
union all
select sr.sys_role_id, ss.name
  from sys_role        sr,
       rel_role_user   rru,
       sys_user        su,
       sys_safety      ss
 where su.sys_user_name = user
   and rru.sys_user_id = su.sys_user_id
   and rru.sys_role_id = sr.sys_role_id
   and sr.sys_role_id = ss.sys_safety_id;

