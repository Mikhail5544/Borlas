create materialized view INS_DWH.MV_CR_POL_ASSURED
build deferred
refresh force on demand
as
select distinct aa.assured_contact_id,                              --ИД застрахованного
       ins.ent.obj_name('CONTACT', c_asset.contact_id) assured_fio,     -- ФИО
       decode(c_asset.gender, 0, 'Ж', 1, 'М') assured_gender,       -- пол
       c_asset.date_of_birth date_of_birth,                         -- дата рождения
       ins.pkg_contact.get_primary_tel(c_asset.contact_id) tel,         --телефон
       ins.pkg_contact.get_primary_doc(c_asset.contact_id) doc,        --документ
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_primary_address(c_asset.contact_id)) address          --адрес
from ins.ven_as_assured aa,
       ins.ven_p_asset_header pah,
       ins.ven_t_asset_type tat,
       ins.ven_cn_person c_asset
where
   aa.p_asset_header_id=pah.p_asset_header_id
   and tat.t_asset_type_id = pah.t_asset_type_id
   and tat.brief = 'ASSET_PERSON_DMS'
   and c_asset.contact_id(+) = aa.assured_contact_id;

