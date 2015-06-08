create materialized view INS_DWH.MV_CR_POL_INSURER
build deferred
refresh force on demand
as
select  ppc.policy_id,
 ppc.contact_id,
 ins.ent.obj_name('CONTACT',ppc.contact_id) full_name,
 ins.pkg_contact.get_primary_tel(ppc.contact_id) telephone,
 ins.pkg_contact.get_primary_doc(ppc.contact_id) document,
 ins.pkg_contact.get_address_name(ins.pkg_contact.get_primary_address(ppc.contact_id)) address,
 ins.pkg_contact.get_birth_date(ppc.contact_id) birth_date,
 ins.pkg_contact.get_sex_char(ins.pkg_contact.get_fio_fmt(ins.ent.obj_name('CONTACT',ppc.contact_id),3)) sex
 from
 ins.ven_p_policy_contact ppc,
 ins.ven_t_contact_pol_role cpr
 where cpr.id = ppc.contact_policy_role_id and cpr.brief = 'Страхователь';

