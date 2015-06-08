create or replace force view ins_dwh.t_contact_type as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION","IS_DEFAULT","IS_INDIVIDUAL","IS_LEAF","IS_LEGAL_ENTITY","UPPER_LEVEL_ID" from ins.ven_t_contact_type;

