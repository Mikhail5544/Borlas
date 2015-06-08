create or replace force view ins_dwh.t_gender as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION","IS_DEFAULT" from ins.ven_t_gender;

