create or replace force view v_pol_office_manager
(policy_id, contact_id, contact_name)
as
select p.policy_id, pc.contact_id, c.obj_name_orig
  from p_policy p left join  (p_policy_contact pc join t_contact_pol_role r on
  	   			  	   		 pc.contact_policy_role_id = r.id  and r.brief='ОфисМенеджер')
			   on p.policy_id = pc.policy_id left join contact c on c.contact_id = pc.contact_id;

