create or replace force view v_curator as
select c.contact_id, fn_obj_name(c.ent_id, c.contact_id) contact_name
  from ven_t_contact_role tcr, ven_contact c, ven_cn_contact_role ccr
 where tcr.description = 'Куратор' and ccr.role_id = tcr.id
 and ccr.contact_id = c.contact_id;

