create or replace force view v_pol_agent as
select pc.policy_id, pc.contact_id, c.obj_name_orig contact_name
  from p_policy_contact pc, t_contact_pol_role cpr, ven_contact c
 where cpr.brief = 'Агент'
   and cpr.id = pc.contact_policy_role_id
   and c.contact_id = pc.contact_id;

