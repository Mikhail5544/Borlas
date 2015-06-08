create or replace force view v_pol_signer as
select pc.policy_id,
	   pc.contact_id,
	   c.obj_name_orig contact_name,
	   pc.ID policy_contact_id
  from p_policy_contact pc, t_contact_pol_role cpr, contact c
 where cpr.brief = 'SIGNER'
   and cpr.id = pc.contact_policy_role_id
   and c.contact_id = pc.contact_id;

