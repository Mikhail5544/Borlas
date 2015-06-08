create or replace force view v_convert_contact as
select C.EXT_ID  from CONVERT_CONTACT_FIS C 
union all 
select C.EXT_ID from CONVERT_CONTACT_UR C 
union all 
select C.EXT_ID from CONVERT_BANK C;

