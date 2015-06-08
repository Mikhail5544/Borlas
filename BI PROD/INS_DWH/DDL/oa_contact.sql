create or replace force view ins_dwh.oa_contact as
select con.CONTACT_ID,
       tct.IS_INDIVIDUAL,
       tcs.name STATUS_NAME,
       con.RESIDENT_FLAG,
       con.NAME,
       con.FIRST_NAME,
       con.MIDDLE_NAME,
       ins.pkg_contact.get_primary_zip(con.contact_id) ZIP,
       ins.pkg_contact.get_contact_kladr(con.contact_id) KLADR,
       NVL(ins.pkg_contact.get_ident_seria(con.contact_id,'PASS_RF'),ins.pkg_contact.get_ident_number(con.contact_id,'VOEN_UDOS')) IDENT_SERIA,
       NVL(ins.pkg_contact.get_ident_number(con.contact_id,'PASS_RF'),ins.pkg_contact.get_ident_number(con.contact_id,'VOEN_UDOS')) IDENT_NUMBER,
       decode(tct.IS_INDIVIDUAL,0,ins.pkg_contact.get_ident_seria(con.contact_id,'INN'),null) INN_SERIA,
       decode(tct.IS_INDIVIDUAL,0,ins.pkg_contact.get_ident_number(con.contact_id,'INN'),null) INN_NUMBER
from ins.ven_contact con
join t_contact_type tct on (tct.id=con.contact_type_id) 
join t_contact_status tcs on tcs.t_contact_status_id=con.T_CONTACT_STATUS_ID;

