create or replace force view v_no_safety_right_role as
select se.sys_role_id, st.safety_right_id
from sys_role se, safety_right st
minus
select srr.role_id, srr.safety_right_id
from safety_right_role srr;

