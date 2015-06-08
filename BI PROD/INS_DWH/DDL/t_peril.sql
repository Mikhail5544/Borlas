create or replace force view ins_dwh.t_peril as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCR_ENG","DESCRIPTION","INSURANCE_GROUP_ID","IS_DEFAULT","IS_DMS_CODE" from ins.ven_t_peril;

