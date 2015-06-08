create or replace force view v_cr_lpu_list as
select distinct
  cont.contact_id,
  ent.obj_name(cont.ent_id, cont.contact_id) contact_name,  --название ЛПУ
  c.dms_lpu_code,                                     --код ЛПУ
 c.latin_name,                                       --латинское название
  ct.description contact_type,
  ent.obj_name('CONTACT',c.boss_id) boss,             --рук-тель
  (select decode(upper(ca.province_name), 'МОСКВА' , ca.province_name, ca.city_name) city
          from ven_cn_address ca
         where ca.id = pkg_contact.get_address_by_brief(cont.contact_id,'FACT')) city, --город
  pkg_contact.get_address_name(pkg_contact.get_address_by_brief(cont.contact_id,'LEGAL')) address_jur,
  pkg_contact.get_address_name(pkg_contact.get_address_by_brief(cont.contact_id,'FACT')) address_fact
from ven_contact cont
join ven_cn_contact_role cr on cr.contact_id = cont.contact_id
                       and cr.role_id = (
                                          select tcr.id from t_contact_role tcr
                                           where tcr.brief = 'LPU'
                                        )
join ven_t_contact_type ct on cont.contact_type_id = ct.id
left join ven_cn_company c on cont.contact_id=c.contact_id
where ct.is_individual = 0
;

