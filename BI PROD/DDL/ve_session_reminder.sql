create or replace force view ve_session_reminder as
select distinct su.sys_user_id
from v$session s
     inner join sys_user su on su.sys_user_name = s.username
     inner join sys_user_reminder sur on sur.sys_user_id = su.sys_user_id
where s.program = 'ifweb90.exe';

