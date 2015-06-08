create or replace force view ins_dwh.t_bonus_malus as
select "T_BONUS_MALUS_ID","ENT_ID","FILIAL_ID","EXT_ID","CLASS","COEF" from ins.ven_T_BONUS_MALUS;

