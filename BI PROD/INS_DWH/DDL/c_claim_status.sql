create or replace force view ins_dwh.c_claim_status as
select "C_CLAIM_STATUS_ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","DESCRIPTION","DOC_STATUS_REF_ID" from ins.ven_c_claim_status;

