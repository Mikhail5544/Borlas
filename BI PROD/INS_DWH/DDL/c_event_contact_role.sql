create or replace force view ins_dwh.c_event_contact_role as
select "C_EVENT_CONTACT_ROLE_ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION" from ins.ven_c_event_contact_role;

