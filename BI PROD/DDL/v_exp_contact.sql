create or replace force view v_exp_contact as
select c.contact_id,
       c.ext_id,
       0 is_uploaded,
       null uploading_date,
       'update' action_type,
       ct.ext_id contact_type,
       c.obj_name_orig full_name,
       (select max(pkg_contact.get_address_name(cca.adress_id))
          from cn_contact_address cca, t_address_type tat
         where cca.contact_id = c.contact_id
           and tat.id = cca.address_type
           and tat.brief = 'LEGAL') legal_adr,
       (select max(pkg_contact.get_address_name(cca.adress_id))
          from cn_contact_address cca, t_address_type tat
         where cca.contact_id = c.contact_id
           and tat.id = cca.address_type
           and tat.brief = 'POSTAL') postal_adr,
       pkg_contact.get_contact_telephones(c.contact_id) phones,
       (select max(cci.id_value)
          from cn_contact_ident cci, t_id_type tit
         where cci.contact_id = c.contact_id
           and cci.id_type = tit.id
           and tit.brief = 'INN') inn,
       docs.serial_nr doc_series,
       docs.id_value doc_number,
       docs.place_of_issue doc_organ,
       docs.issue_date doc_date,
       p.date_of_birth birth_date,
       --p.date_of_death date_death,
       docs.ext_id doc_type,
       ca.zip adr_index,
       ent.obj_name(ca.ent_id, ca.id) adr_kladr,
       g.ext_id gender,
       FN_GET_OCATD(ca.id) okato
  from contact c,
       t_contact_type ct,
       (select cci.contact_id,
               row_number() over(partition by cci.contact_id order by cci.issue_date desc) rn,
               cci.serial_nr,
               cci.issue_date,
               cci.id_value,
               cci.place_of_issue,
               tit.ext_id
          from cn_contact_ident cci, t_id_type tit
         where tit.id = cci.id_type
           and tit.is_default = 1) docs,
       cn_person p,
       t_gender g,
       cn_address ca
 where c.contact_type_id = ct.id
   and c.contact_id = docs.contact_id(+)
   and docs.rn(+) = 1
   and p.contact_id(+) = c.contact_id
   and p.gender = g.id(+)
   and ca.id(+) = pkg_contact.get_primary_address(c.contact_id)
;

