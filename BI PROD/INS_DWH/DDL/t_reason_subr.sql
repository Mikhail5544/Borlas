create or replace force view ins_dwh.t_reason_subr as
select "T_REASON_SUBR_ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","IS_DEFAULT","REASON_SUBR" from ins.ven_t_reason_subr;

