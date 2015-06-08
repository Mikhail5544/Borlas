create or replace force view v_bank_list as
select distinct
  c.contact_id,
  c.obj_name_orig contact_name,
  c.first_name,
  c.middle_name,
  c.latin_name,
  ct.description contact_type,
  pkg_contact.get_address_name(ca.adress_id) address_name 
from contact c
join cn_contact_role cr on cr.contact_id = c.contact_id
                       and cr.role_id = (
                                          select tcr.id from t_contact_role tcr
                                           where tcr.description = 'Банк'
                                        )
join t_contact_type ct on c.contact_type_id = ct.id
join cn_contact_address ca on ca.contact_id = c.contact_id and
                              ca.id = (
                                        select max(ca2.id) from cn_contact_address ca2
                                        where ca2.contact_id = c.contact_id
                                      );

