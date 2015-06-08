create or replace force view ins_dwh.t_contact_status as
select "T_CONTACT_STATUS_ID","ENT_ID","FILIAL_ID","EXT_ID","DESCRIPTION","IS_DEFAULT","NAME" from ins.ven_t_contact_status;

