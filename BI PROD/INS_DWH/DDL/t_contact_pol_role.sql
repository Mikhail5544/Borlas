create or replace force view ins_dwh.t_contact_pol_role as
select "ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION","IS_DEFAULT" from ins.ven_t_contact_pol_role;

