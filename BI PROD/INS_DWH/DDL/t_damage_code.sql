create or replace force view ins_dwh.t_damage_code as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","CODE","DESCRIPTION","IS_DEFAULT","IS_DMS_CODE","IS_INSURANCE","IS_REFUNDABLE","LIMIT_VAL","PARENT_ID","PERIL","T_PROD_COEF_TYPE_ID" from ins.ven_t_damage_code;

