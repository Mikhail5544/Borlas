create or replace view ins_dwh.v_reserves_vs_profit_cover_ag as
SELECT MIN(pcm.start_date) AS program_start
      ,MAX(pcm.end_date) AS program_end
      ,SUM(CASE
             WHEN aam.status_hist_id != 3
                  AND pcm.status_hist_id != 3 THEN
              pcm.ins_amount
             ELSE
              0
           END) AS program_sum
      ,aam.p_policy_id
      ,pcm.t_prod_line_option_id
  FROM ins.as_asset aam
      ,ins.p_cover  pcm
 WHERE aam.as_asset_id = pcm.as_asset_id
   AND aam.p_policy_id IN (SELECT ph.policy_id
                             FROM ins.p_pol_header ph
                                 ,ins.t_product    pr
                                 ,ins.p_policy     pp
                            WHERE ph.product_id = pr.product_id
                              AND ph.policy_id = pp.policy_id)
 GROUP BY aam.p_policy_id
         ,pcm.t_prod_line_option_id;
