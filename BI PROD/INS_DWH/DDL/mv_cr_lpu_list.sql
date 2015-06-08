create materialized view INS_DWH.MV_CR_LPU_LIST
build deferred
refresh force on demand
as
select distinct cont.contact_id,
                ins.ent.obj_name(cont.ent_id, cont.contact_id) contact_name, --название ЛПУ
                c.dms_lpu_code, --код ЛПУ
                c.latin_name, --латинское название
                ct.description contact_type,
                ins.ent.obj_name('CONTACT', c.boss_id) boss, --рук-тель
                q.city, --город
                ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(cont.contact_id,
                                                                                  'LEGAL')) address_jur,
                ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(cont.contact_id,
                                                                                  'FACT')) address_fact
  from ins.ven_contact cont
  join ins.ven_cn_contact_role cr on cr.contact_id = cont.contact_id
                                 and cr.role_id =
                                     (select tcr.id
                                        from ins.t_contact_role tcr
                                       where tcr.brief = 'LPU')
  join ins.ven_t_contact_type ct on cont.contact_type_id = ct.id
  left join ins.ven_cn_company c on cont.contact_id = c.contact_id
  left join (select ca.id, decode(upper(ca.province_name), 'МОСКВА', ca.province_name, ca.city_name) city
               from ins.ven_cn_address ca) q on q.id =
                                                ins.pkg_contact.get_address_by_brief(cont.contact_id,
                                                                                     'FACT')
 where ct.is_individual = 0;

