create materialized view INS_DWH.PRE_COVER_CHARGING_IFRS
refresh force on demand
as
select charging_ifrs1.s, pc_1.p_cover_id
          from (select sum(t1.trans_amount) s,
                        t1.a3_ct_uro_id p_asset_header_id,
                        t1.a4_ct_uro_id t_prod_line_option_id --, t1.trans_date
                   from ins.ven_trans t1
                  where

               t1.ct_account_id = 551

                  group by t1.a3_ct_uro_id,
                        t1.a4_ct_uro_id

                 ) charging_ifrs1,
               ins.p_cover pc_1
         where charging_ifrs1.p_asset_header_id = pc_1.as_asset_id
           and charging_ifrs1.t_prod_line_option_id =
               pc_1.t_prod_line_option_id;

