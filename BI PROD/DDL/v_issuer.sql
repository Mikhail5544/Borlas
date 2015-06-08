create or replace force view v_issuer as
select c.contact_id, c.short_name contact_name, c.ent_id ent_id
  from ven_t_contact_role tcr, ven_contact c, ven_cn_contact_role ccr
 where tcr.description = 'Страхователь' and ccr.role_id = tcr.id
 and ccr.contact_id = c.contact_id;

