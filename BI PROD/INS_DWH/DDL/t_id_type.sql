create or replace force view ins_dwh.t_id_type as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION","ID_TYPE_FORMAT_ID","IS_DEFAULT","SORT_ORDER" from ins.ven_t_id_type;

