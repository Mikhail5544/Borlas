create or replace view INS_DWH.V_RESERVES_VS_PROFIT_COVER_AG
as
select min(pcm.start_date) as program_start
      ,max(pcm.end_date)   as program_end
      ,sum(case  
             when aam.status_hist_id != 3 and pcm.status_hist_id != 3 then
               pcm.ins_amount
             else 0
           end
          ) as program_sum
      ,aam.p_policy_id
      ,pcm.t_prod_line_option_id
  from ins.as_asset aam
      ,ins.p_cover  pcm
 where aam.as_asset_id = pcm.as_asset_id
   and aam.p_policy_id in (select ph.policy_id
                             from ins.p_pol_header ph
                                 ,ins.t_product    pr
                                 ,ins.p_policy     pp
                            where ph.product_id = pr.product_id
                              and ph.policy_id  = pp.policy_id
                              and ((ins_dwh.pkg_reserves_vs_profit.get_mode = 0
                                    and pr.brief not in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                                    and pp.is_group_flag = 0
                                   )or
                                   (ins_dwh.pkg_reserves_vs_profit.get_mode = 1
                                    and pr.brief in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                                   )or
                                   (ins_dwh.pkg_reserves_vs_profit.get_mode = 2
                                    and pp.is_group_flag = 1
                                   )
                                  )
                          )
 group by aam.p_policy_id, pcm.t_prod_line_option_id;
