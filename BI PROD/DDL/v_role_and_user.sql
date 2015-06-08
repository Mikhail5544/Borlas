create or replace force view v_role_and_user as
select sys_role_id sys_safety_id, /*'(*) ' || name */ name from ven_sys_role;

