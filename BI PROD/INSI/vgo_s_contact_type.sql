create or replace force view vgo_s_contact_type as
select "ID","DESCRIPTION","IS_INDIVIDUAL","IS_LEGAL_ENTITY","IS_LEAF","UPPER_LEVEL_ID","IS_DEFAULT","ENT_ID","FILIAL_ID","EXT_ID","BRIEF" from   ins.T_CONTACT_TYPE;

