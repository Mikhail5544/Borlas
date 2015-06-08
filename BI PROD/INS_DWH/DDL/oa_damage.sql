create or replace force view ins_dwh.oa_damage as
select d.C_DAMAGE_ID,
       d.C_CLAIM_ID,
       d.C_DAMAGE_STATUS_ID,
       d.C_DAMAGE_TYPE_ID,
       d.T_DAMAGE_CODE_ID,
       d.DECLARE_SUM,
       d.PAYMENT_SUM
from ins.ven_c_damage d;

