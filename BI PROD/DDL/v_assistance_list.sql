create or replace force view v_assistance_list as
select distinct
  c.contact_id,
  cont.dms_lpu_code,
  ent.obj_name(c.ent_id, c.contact_id) contact_name,
  c.first_name,
  c.middle_name,
  c.latin_name,
  ct.description contact_type,
  pkg_contact.get_address_name(pkg_contact.get_address_by_brief(c.contact_id,'LEGAL')) address_jur,
  pkg_contact.get_address_name(pkg_contact.get_address_by_brief(c.contact_id,'FACT')) address_fact
from contact c
join cn_contact_role cr on cr.contact_id = c.contact_id
                       and cr.role_id in (
                                          select tcr.id from t_contact_role tcr
                                           where tcr.brief in ('LPU')
                                        )
join ven_t_contact_type ct on c.contact_type_id = ct.id
left join ven_cn_company cont on cont.contact_id=c.contact_id
where ct.is_individual = 0;

