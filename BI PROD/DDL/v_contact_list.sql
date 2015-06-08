create or replace force view v_contact_list as
select c.contact_id,
       c.obj_name_orig contact_name,
       c.latin_name,
       ct.description contact_type,
       ent.obj_name('CN_ADDRESS', pkg_contact.get_primary_address(c.contact_id)) address_name
  from contact c join t_contact_type ct on c.contact_type_id = ct.id;

