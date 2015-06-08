create or replace force view v_office_manager as
select c.contact_id, c.obj_name_orig contact_name
	  from ven_t_contact_role tcr, ven_contact c, ven_cn_contact_role ccr
	 where tcr.BRIEF = 'нтлем' and ccr.role_id = tcr.id
	 and ccr.contact_id = c.contact_id;

