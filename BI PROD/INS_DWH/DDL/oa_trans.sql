create or replace force view ins_dwh.oa_trans as
select t.TRANS_ID,
       t.a1_ct_uro_id,
       t.a2_ct_uro_id,
       t.a3_ct_uro_id,
       t.a4_ct_uro_id,
       t.a5_ct_uro_id,
       t.a1_dt_uro_id,
       t.a2_dt_uro_id,
       t.a3_dt_uro_id,
       t.a4_dt_uro_id,
       t.a5_dt_uro_id,
       t.TRANS_AMOUNT,
       t.TRANS_DATE,
       t.TRANS_TEMPL_ID  
from ins.ven_trans t;

