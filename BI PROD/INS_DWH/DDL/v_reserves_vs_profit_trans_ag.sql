create or replace force view ins_dwh.v_reserves_vs_profit_trans_ag as
select nvl(sum(t1.trans_amount),0) as charge_premium
        ,t1.a3_ct_uro_id             as p_asset_header_id
        ,t1.a4_ct_uro_id             as t_prod_line_option_id
    from ins.trans t1 
   where t1.ct_account_id = 186
     and t1.a3_ct_ure_id = 302
     and t1.a4_ct_ure_id = 310
   group by t1.a3_ct_uro_id, t1.a4_ct_uro_id;

