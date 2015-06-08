create materialized view INS_DWH.MV_CR_POL_INSURED
build deferred
refresh force on demand
as
select
 ass.p_policy_id,
 assur.as_assured_id contact_id,
 ins.ent.obj_name('CONTACT',assur.assured_contact_id) as full_name,
 ins.pkg_contact.get_primary_tel(assur.assured_contact_id) telephone,
 ins.pkg_contact.get_primary_doc(assur.assured_contact_id) document,
 ins.pkg_contact.get_address_name(ins.pkg_contact.get_primary_address(assur.assured_contact_id)) address,
 ins.pkg_contact.get_birth_date(assur.assured_contact_id) birth_date,
 ins.pkg_contact.get_sex_char(ins.pkg_contact.get_fio_fmt(ins.ent.obj_name('CONTACT',assur.assured_contact_id),3)) sex,
 ins.pkg_contact.get_profession (assur.assured_contact_id) as profession
 from  ins.ven_as_asset ass
 join ins.ven_as_assured assur on assur.as_assured_id = ass.as_asset_id;

