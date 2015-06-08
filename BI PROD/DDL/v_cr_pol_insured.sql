create or replace force view v_cr_pol_insured
(policy_id, contact_id, full_name, telephone, document, address, birth_date, sex, profession)
as
select
 ass.p_policy_id,
 assur.as_assured_id,
 ent.obj_name('CONTACT',assur.assured_contact_id) as fio,
 pkg_contact.get_primary_tel(assur.assured_contact_id) tel,
 pkg_contact.get_primary_doc(assur.assured_contact_id) doc,
 pkg_contact.get_address_name(pkg_contact.get_primary_address(assur.assured_contact_id)) address,
 pkg_contact.get_birth_date(assur.assured_contact_id) birth_date,
 pkg_contact.get_sex_char(pkg_contact.get_fio_fmt(ent.obj_name('CONTACT',assur.assured_contact_id),3)) sex,
 pkg_contact.get_profession (assur.assured_contact_id) as profession
 from  ven_as_asset ass
 join ven_as_assured assur on assur.as_assured_id = ass.as_asset_id;

