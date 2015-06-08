create or replace force view v_active_fund as
select 
    "FUND_ID","ENT_ID","FILIAL_ID","NAME","BRIEF","CODE","ADD_CODE","PRECISION","RATE_QTY","SPELL_1_WHOLE","SPELL_2_WHOLE","SPELL_5_WHOLE","SPELL_1_FRACT","SPELL_2_FRACT","SPELL_5_FRACT","IS_ACTIVE"
  from 
    Fund f
  where
    f.is_active = 1;

