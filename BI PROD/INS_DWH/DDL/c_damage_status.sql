create or replace force view ins_dwh.c_damage_status as
select "C_DAMAGE_STATUS_ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION" from ins.ven_c_damage_status;

