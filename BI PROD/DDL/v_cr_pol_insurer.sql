create or replace force view v_cr_pol_insurer
(policy_id, contact_id, full_name, telephone, document, address, birth_date, sex, email)
as
select  ppc.policy_id,
 ppc.contact_id,
 ent.obj_name('CONTACT',ppc.contact_id),
 pkg_contact.get_primary_tel(ppc.contact_id) tel,
 pkg_contact.get_primary_doc(ppc.contact_id) doc,
 pkg_contact.get_address_name(pkg_contact.get_primary_address(ppc.contact_id)) address,
 pkg_contact.get_birth_date(ppc.contact_id) birth_date,
 pkg_contact.get_sex_char(pkg_contact.get_fio_fmt(ent.obj_name('CONTACT',ppc.contact_id),3)) sex,
 pkg_contact.get_emales(ppc.contact_id) email
 from
 ven_p_policy_contact ppc,
 ven_t_contact_pol_role cpr
 where cpr.id = ppc.contact_policy_role_id and cpr.brief = 'Страхователь';

