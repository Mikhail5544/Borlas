create or replace force view v_pol_beneficiary as
select pc.policy_id, 
	   pc.contact_id, 
	   c.obj_name_orig contact_name, 
	   pc.ID as policy_contact_id 
  from p_policy_contact pc, t_contact_pol_role cpr, ven_contact c 
 where UPPER(cpr.brief) = UPPER('Выгодоприобретатель') 
   and cpr.id = pc.contact_policy_role_id 
   and c.contact_id = pc.contact_id;

